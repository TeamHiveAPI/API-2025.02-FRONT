import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';
import fs from 'fs/promises';
import path from 'path';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("As variáveis não foram identificadas!");
}

// Troque pelo caminho do seu computador
const CAMINHO_DA_IMAGEM_LOCAL = 'D:/API-2025.02-FRONT/assets/foto-perfil-teste.png';

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function criarUsuarioComFoto() {
  console.log('Iniciando processo de criação de usuário com upload de foto...');

  const dadosIniciaisUsuario = {
    email: 'coronel@eb.mil.br',
    password: '123456',
    email_confirm: true,
    user_metadata: {
      display_name: 'Coronel',
      cpf: '777777777',
      nivel_acesso: 3,
      id_setor: 1,
    }
  };

  console.log('Criando registro de autenticação do usuário...');
  const { data: userData, error: userError } = await supabase.auth.admin.createUser(dadosIniciaisUsuario);

  if (userError) {
    console.error('Erro ao criar o usuário:', userError.message);
    return;
  }

  const novoUserId = userData.user.id;
  console.log(`Usuário criado com ID: ${novoUserId}`);

  try {
    console.log(`Lendo arquivo de imagem de: ${CAMINHO_DA_IMAGEM_LOCAL}`);
    const fileBuffer = await fs.readFile(CAMINHO_DA_IMAGEM_LOCAL);
    const fileExt = path.extname(CAMINHO_DA_IMAGEM_LOCAL).substring(1);
    const filePath = `${novoUserId}/avatar.${fileExt}`;

    console.log(`Fazendo upload para o Storage em: user-avatars/${filePath}`);
    const { error: uploadError } = await supabase.storage
      .from('user-avatars')
      .upload(filePath, fileBuffer, {
        upsert: true,
        contentType: `image/${fileExt}`
      });

    if (uploadError) {
      throw uploadError;
    }
    console.log('Upload concluído com sucesso!');

    console.log(`Atualizando metadados do usuário com o caminho: ${filePath}`);
    const { data: updatedUser, error: updateError } = await supabase.auth.admin.updateUserById(
      novoUserId,
      {
        user_metadata: { ...dadosIniciaisUsuario.user_metadata, foto_url: filePath }
      }
    );

    if (updateError) {
      throw updateError;
    }

    console.log('Usuário com foto criado com sucesso!');

  } catch (error) {
    console.error('Ocorreu um erro durante o upload da foto ou atualização do usuário:', error.message);
    console.log('O usuário foi criado na autenticação, mas a foto falhou. Considere apagar o usuário de teste ou corrigir o erro e tentar novamente.');
  }
}

criarUsuarioComFoto();