import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4'

const BUCKET_NAME = 'user-avatars'
const CORS_HEADERS = { 
  'Access-Control-Allow-Origin': '*', 
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type' 
};

serve(async (req) => {
  console.log('[LOG] Função (v2) create-signed-avatar-url iniciada.');

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  try {
    const { userId } = await req.json();
    if (!userId) throw new Error("userId é obrigatório.");

    console.log(`[LOG] Payload recebido. userId: ${userId}`);

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const filePath = `${userId}/avatar.png`;
    console.log(`[LOG] Caminho do arquivo: ${filePath}`);

    console.log(`[LOG] Tentando remover o arquivo antigo em: ${filePath}`);
    const { error: removeError } = await supabaseAdmin
      .storage
      .from(BUCKET_NAME)
      .remove([filePath]);

    if (removeError && removeError.message !== 'The resource was not found') {
      console.error('[ERRO] Erro ao remover o arquivo antigo:', JSON.stringify(removeError));
      throw removeError;
    }
    console.log('[LOG] Remoção do arquivo antigo concluída (ou ele não existia).');
    
    console.log('[LOG] Criando nova Signed Upload URL...');
    const { data, error } = await supabaseAdmin
      .storage
      .from(BUCKET_NAME)
      .createSignedUploadUrl(filePath);

    if (error) {
      console.error('[ERRO] Erro ao criar a Signed Upload URL:', JSON.stringify(error));
      throw error;
    }

    console.log('[LOG] Signed URL criada com sucesso.');
    
    return new Response(JSON.stringify({ signedUrl: data.signedUrl, path: data.path }), {
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    console.error('[ERRO] Erro no bloco catch principal:', error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
})