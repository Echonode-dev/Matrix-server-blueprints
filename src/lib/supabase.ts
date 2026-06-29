import { createClient } from '@supabase/supabase-js';

// Use environment variables first, fallback to the provided keys
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://hihhdnyhtncusmdzteuc.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpaGhkbnlodG5jdXNtZHp0ZXVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2NDUwNDAsImV4cCI6MjA5NjIyMTA0MH0.xcpMyisVL1F3Ol6lhz03iu_HXxQef0Bqpo3Wjc-w8MI';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
