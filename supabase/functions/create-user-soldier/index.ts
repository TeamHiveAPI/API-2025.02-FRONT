import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4'

function generatePassword() {
  const length = 8;
  const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  const specials = '!@#$%^&*()_+~`|}{[]:;?><,./-=';
  const allChars = uppercase.toLowerCase() + uppercase + numbers + specials;

  let password = '';
  password += uppercase[Math.floor(Math.random() * uppercase.length)];
  password += numbers[Math.floor(Math.random() * numbers.length)];
  password += specials[Math.floor(Math.random() * specials.length)];

  for (let i = password.length; i < length; i++) {
    password += allChars[Math.floor(Math.random() * allChars.length)];
  }

  return password.split('').sort(() => 0.5 - Math.random()).join('');
}


serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    const { name, email, cpf, viewingSectorId } = await req.json();
    if (!name || !email || !cpf || !viewingSectorId) {
      throw new Error("Dados incompletos para criar o soldado.");
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const { data: existingUser, error: existingUserError } = await supabaseAdmin
      .from('usuario')
      .select('usr_email, usr_cpf')
      .or(`usr_email.eq.${email},usr_cpf.eq.${cpf}`)
      .limit(1);

    if (existingUserError) {
      throw new Error(`Erro ao verificar usuário existente: ${existingUserError.message}`);
    }

    if (existingUser && existingUser.length > 0) {
      const duplicate = existingUser[0];
      if (duplicate.usr_email === email) {
        throw new Error('EMAIL_EXISTS');
      }
      if (duplicate.usr_cpf === cpf) {
        throw new Error('CPF_EXISTS');
      }
    }

    const initialPassword = generatePassword();

    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: email,
      password: initialPassword,
      email_confirm: true,
      user_metadata: { 
        display_name: name, 
        cpf: cpf, 
        nivel_acesso: 1, 
        id_setor: viewingSectorId 
      },
    });

    if (authError) { throw authError; }
    if (!authData.user) { throw new Error('Falha ao criar usuário no Auth.'); }

    const { error: profileError } = await supabaseAdmin
      .from('usuario')
      .upsert({
        usr_auth_uid: authData.user.id,
        usr_nome: name,
        usr_email: email,
        usr_cpf: cpf,
        usr_nivel_acesso: 1,
        usr_setor_id: viewingSectorId
      }, {
        onConflict: 'usr_auth_uid'
      });
      
    if (profileError) {
      await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
      throw profileError;
    }

    return new Response(JSON.stringify({ 
      message: "Soldado criado com sucesso!",
      password: initialPassword,
      userId: authData.user.id
    }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      status: 200,
    });

  } catch (error: any) {
    const headers = { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' };
    
    if (error.message === 'EMAIL_EXISTS' || error.message?.includes('User already registered')) {
      return new Response(JSON.stringify({ error: 'Este e-mail já está em uso.' }), {
        headers,
        status: 409,
      });
    }

    if (error.message === 'CPF_EXISTS') {
      return new Response(JSON.stringify({ error: 'Este CPF já está cadastrado.' }), {
        headers,
        status: 409,
      });
    }

    return new Response(JSON.stringify({ error: error.message }), {
      headers,
      status: 400,
    });
  }
})