ALTER TABLE public.songs 
ADD COLUMN IF NOT EXISTS artist TEXT NOT NULL DEFAULT '';

NOTIFY pgrst, 'reload schema';
