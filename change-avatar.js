import 'dotenv/config';
import fs from 'fs';
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("As variáveis não foram identificadas!");
}

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const bucketName = 'user-avatars';
const filePath = 'MUDAR-AQUI/avatar.png';
const localFilePath = 'MUDAR-AQUI';

async function replaceImage() {
  try {
    const fileBuffer = fs.readFileSync(localFilePath);

    const { data, error: uploadError } = await supabase
      .storage
      .from(bucketName)
      .upload(filePath, fileBuffer, { upsert: true });

    if (uploadError) throw uploadError;
    console.log('Imagem substituída com sucesso!');

  } catch (err) {
    console.error('Erro:', err.message);
  }
}

replaceImage();
