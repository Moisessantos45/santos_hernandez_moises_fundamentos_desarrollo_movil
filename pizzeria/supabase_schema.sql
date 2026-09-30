-- ==============================================================================
-- SCHEMA Y TABLAS PARA PIZZAPP (SUPABASE POSTGRESQL)
-- ==============================================================================

-- 1. EXTENSIONES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABLA: profiles (Perfiles de usuarios vinculados a auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('comprador', 'vendedor')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. TABLA: restaurants (Pizzerías / Locales registrados por vendedores)
CREATE TABLE IF NOT EXISTS public.restaurants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL DEFAULT 19.432608,
    longitude DOUBLE PRECISION NOT NULL DEFAULT -99.133209,
    phone TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. TABLA: pizzas (Catálogo de pizzas por restaurante)
CREATE TABLE IF NOT EXISTS public.pizzas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    image_url TEXT NOT NULL,
    sizes JSONB NOT NULL DEFAULT '["Personal", "Mediana", "Familiar"]'::jsonb,
    category TEXT NOT NULL DEFAULT 'Clasicas',
    rating NUMERIC(3, 1) NOT NULL DEFAULT 5.0,
    reviews_count INT NOT NULL DEFAULT 0,
    is_available BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. TABLA: orders (Pedidos realizados por compradores)
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    buyer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE RESTRICT,
    status TEXT NOT NULL DEFAULT 'pendiente' CHECK (status IN ('pendiente', 'en_preparacion', 'en_camino', 'entregado', 'cancelado')),
    total_amount NUMERIC(10, 2) NOT NULL,
    delivery_address TEXT NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'Efectivo',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. TABLA: order_items (Items individuales de cada pedido)
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    pizza_id UUID REFERENCES public.pizzas(id) ON DELETE SET NULL,
    pizza_name TEXT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL,
    size TEXT NOT NULL DEFAULT 'Mediana',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. TABLA: cart_items (Carrito de compras persistente en la Base de Datos)
CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    pizza_id UUID NOT NULL REFERENCES public.pizzas(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    size TEXT NOT NULL DEFAULT 'Mediana',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, pizza_id, size)
);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pizzas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- Políticas para Profiles
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Perfiles visibles para usuarios autenticados" ON public.profiles;
CREATE POLICY "Perfiles visibles para usuarios autenticados"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Usuarios pueden insertar su propio perfil" ON public.profiles;
CREATE POLICY "Usuarios pueden insertar su propio perfil"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Usuarios pueden actualizar su propio perfil" ON public.profiles;
CREATE POLICY "Usuarios pueden actualizar su propio perfil"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);

-- ------------------------------------------------------------------------------
-- Políticas para Restaurants
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Restaurantes visibles públicamente" ON public.restaurants;
CREATE POLICY "Restaurantes visibles públicamente"
    ON public.restaurants FOR SELECT
    TO authenticated, anon
    USING (true);

DROP POLICY IF EXISTS "Vendedores pueden crear restaurante" ON public.restaurants;
CREATE POLICY "Vendedores pueden crear restaurante"
    ON public.restaurants FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = seller_id);

DROP POLICY IF EXISTS "Vendedores pueden actualizar su restaurante" ON public.restaurants;
CREATE POLICY "Vendedores pueden actualizar su restaurante"
    ON public.restaurants FOR UPDATE
    TO authenticated
    USING (auth.uid() = seller_id);

-- ------------------------------------------------------------------------------
-- Políticas para Pizzas
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Pizzas visibles públicamente" ON public.pizzas;
CREATE POLICY "Pizzas visibles públicamente"
    ON public.pizzas FOR SELECT
    TO authenticated, anon
    USING (true);

DROP POLICY IF EXISTS "Vendedores pueden insertar pizzas en sus restaurantes" ON public.pizzas;
CREATE POLICY "Vendedores pueden insertar pizzas en sus restaurantes"
    ON public.pizzas FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.restaurants
            WHERE restaurants.id = pizzas.restaurant_id
            AND restaurants.seller_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Vendedores pueden actualizar pizzas de sus restaurantes" ON public.pizzas;
CREATE POLICY "Vendedores pueden actualizar pizzas de sus restaurantes"
    ON public.pizzas FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.restaurants
            WHERE restaurants.id = pizzas.restaurant_id
            AND restaurants.seller_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Vendedores pueden eliminar pizzas de sus restaurantes" ON public.pizzas;
CREATE POLICY "Vendedores pueden eliminar pizzas de sus restaurantes"
    ON public.pizzas FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.restaurants
            WHERE restaurants.id = pizzas.restaurant_id
            AND restaurants.seller_id = auth.uid()
        )
    );

-- ------------------------------------------------------------------------------
-- Políticas para Orders
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Compradores y Vendedores pueden ver sus pedidos" ON public.orders;
CREATE POLICY "Compradores y Vendedores pueden ver sus pedidos"
    ON public.orders FOR SELECT
    TO authenticated
    USING (
        buyer_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.restaurants
            WHERE restaurants.id = orders.restaurant_id
            AND restaurants.seller_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Compradores pueden crear pedidos" ON public.orders;
CREATE POLICY "Compradores pueden crear pedidos"
    ON public.orders FOR INSERT
    TO authenticated
    WITH CHECK (buyer_id = auth.uid());

DROP POLICY IF EXISTS "Vendedores pueden actualizar el estado de pedidos" ON public.orders;
CREATE POLICY "Vendedores pueden actualizar el estado de pedidos"
    ON public.orders FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.restaurants
            WHERE restaurants.id = orders.restaurant_id
            AND restaurants.seller_id = auth.uid()
        )
    );

-- ------------------------------------------------------------------------------
-- Políticas para Order Items
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Items de orden visibles por participantes del pedido" ON public.order_items;
CREATE POLICY "Items de orden visibles por participantes del pedido"
    ON public.order_items FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND (
                orders.buyer_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM public.restaurants
                    WHERE restaurants.id = orders.restaurant_id
                    AND restaurants.seller_id = auth.uid()
                )
            )
        )
    );

DROP POLICY IF EXISTS "Compradores pueden insertar items de su pedido" ON public.order_items;
CREATE POLICY "Compradores pueden insertar items de su pedido"
    ON public.order_items FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE orders.id = order_items.order_id
            AND orders.buyer_id = auth.uid()
        )
    );

-- ------------------------------------------------------------------------------
-- Políticas para Cart Items (Carrito en DB)
-- ------------------------------------------------------------------------------
DROP POLICY IF EXISTS "Usuarios pueden ver su propio carrito" ON public.cart_items;
CREATE POLICY "Usuarios pueden ver su propio carrito"
    ON public.cart_items FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuarios pueden insertar en su propio carrito" ON public.cart_items;
CREATE POLICY "Usuarios pueden insertar en su propio carrito"
    ON public.cart_items FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuarios pueden actualizar su propio carrito" ON public.cart_items;
CREATE POLICY "Usuarios pueden actualizar su propio carrito"
    ON public.cart_items FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuarios pueden eliminar de su propio carrito" ON public.cart_items;
CREATE POLICY "Usuarios pueden eliminar de su propio carrito"
    ON public.cart_items FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- 8. TRIGGER AUTOMÁTICO: AUTO-CONFIRMAR CORREOS Y SINCRONIZAR auth.users
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.auto_confirm_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    NEW.email_confirmed_at := COALESCE(NEW.email_confirmed_at, NOW());
    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.auto_confirm_new_user() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.auto_confirm_new_user() FROM anon;
REVOKE EXECUTE ON FUNCTION public.auto_confirm_new_user() FROM authenticated;

DROP TRIGGER IF EXISTS on_auth_user_auto_confirm ON auth.users;
CREATE TRIGGER on_auth_user_auto_confirm
    BEFORE INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_confirm_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.email, ''),
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(COALESCE(NEW.email, 'usuario'), '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'comprador')
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role;
    RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM authenticated;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Sincronizar usuarios existentes en auth.users que no tengan fila en public.profiles
INSERT INTO public.profiles (id, email, full_name, role)
SELECT 
    id, 
    COALESCE(email, ''), 
    COALESCE(raw_user_meta_data->>'full_name', split_part(COALESCE(email, 'usuario'), '@', 1)), 
    COALESCE(raw_user_meta_data->>'role', 'comprador')
FROM auth.users
ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- 9. SUPABASE REALTIME (PUBLICACIÓN PARA WEBSOCKETS EN TIEMPO REAL)
-- ==============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE public.order_items;
ALTER PUBLICATION supabase_realtime ADD TABLE public.pizzas;
ALTER PUBLICATION supabase_realtime ADD TABLE public.restaurants;
ALTER PUBLICATION supabase_realtime ADD TABLE public.cart_items;

