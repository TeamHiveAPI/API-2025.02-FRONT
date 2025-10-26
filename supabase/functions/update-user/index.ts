import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { userId, email, metadata, atualizar_data_cargo } = await req.json()

    if (!userId) {
      throw new Error('O ID do usuário (userId) é obrigatório.')
    }

    const { data: { user: currentUser }, error: userError } = await supabaseAdmin.auth.admin.getUserById(userId);
    if(userError) throw userError;
    
    const oldPhotoUrl = currentUser?.user_metadata?.foto_url;
    const newPhotoUrl = metadata?.foto_url;

    if (oldPhotoUrl && !newPhotoUrl) {
      await supabaseAdmin.storage.from('user_avatars').remove([oldPhotoUrl]);
    }
    
    const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
      userId,
      { email: email, user_metadata: metadata }
    )

    if (error) {
      console.error('Erro ao atualizar usuário no Auth:', error)
      throw new Error(error.message)
    }

    if (atualizar_data_cargo === true) {
      const today = new Date().toISOString().split('T')[0];
      
      const { error: tableError } = await supabaseAdmin
        .from('usuario')
        .update({ usr_data_criacao: today })
        .eq('usr_auth_uid', userId);

      if (tableError) {
        console.error('Falha ao atualizar usr_data_criacao:', tableError);
      }
    }

    return new Response(JSON.stringify({ success: true, user: data.user }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})