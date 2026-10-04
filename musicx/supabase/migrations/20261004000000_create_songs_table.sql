CREATE TABLE IF NOT EXISTS public.songs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid(),
    title TEXT NOT NULL,
    artist TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL DEFAULT '',
    image_url TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_songs_user_id ON public.songs(user_id);
CREATE INDEX IF NOT EXISTS idx_songs_user_created_at ON public.songs(user_id, created_at DESC);

DROP POLICY IF EXISTS "Users can view their own songs" ON public.songs;
CREATE POLICY "Users can view their own songs"
ON public.songs
FOR SELECT
TO authenticated
USING ( (SELECT auth.uid()) = user_id );

DROP POLICY IF EXISTS "Users can insert their own songs" ON public.songs;
CREATE POLICY "Users can insert their own songs"
ON public.songs
FOR INSERT
TO authenticated
WITH CHECK ( (SELECT auth.uid()) = user_id );

DROP POLICY IF EXISTS "Users can update their own songs" ON public.songs;
CREATE POLICY "Users can update their own songs"
ON public.songs
FOR UPDATE
TO authenticated
USING ( (SELECT auth.uid()) = user_id )
WITH CHECK ( (SELECT auth.uid()) = user_id );

DROP POLICY IF EXISTS "Users can delete their own songs" ON public.songs;
CREATE POLICY "Users can delete their own songs"
ON public.songs
FOR DELETE
TO authenticated
USING ( (SELECT auth.uid()) = user_id );

GRANT SELECT, INSERT, UPDATE, DELETE ON public.songs TO authenticated;

NOTIFY pgrst, 'reload schema';
