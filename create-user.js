import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';
import fs from 'fs/promises';
import path from 'path';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("As variáveis não foram identificadas!");
}

// Caminho da imagem de perfil
const CAMINHO_DA_IMAGEM_LOCAL = './assets/foto-perfil-teste.png';

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

// Lista de usuários para criar
const usuariosParaCriar = [
  {
    email: 'coronel@eb.mil.br',
    password: '123456',
    nome: 'Coronel Silva',
    cpf: '11111111111',
    nivel_acesso: 3,
    id_setor: 0, // Coronel pode acessar todos os setores
  },
  {
    email: 'tenenteEstoque@eb.mil.br',
    password: '123456',
    nome: 'Tenente Estoque',
    cpf: '22222222222',
    nivel_acesso: 2,
    id_setor: 1, // Almoxarifado
  },
  {
    email: 'tenenteFarmacia@eb.mil.br',
    password: '123456',
    nome: 'Tenente Farmácia',
    cpf: '33333333333',
    nivel_acesso: 2,
    id_setor: 2, // Farmácia
  },
  {
    email: 'tenenteOdonto@eb.mil.br',
    password: '123456',
    nome: 'Tenente Odonto',
    cpf: '44444444444',
    nivel_acesso: 2,
    id_setor: 3, // Odontologia
  },
  {
    email: 'soldadoEstoque@eb.mil.br',
    password: '123456',
    nome: 'Soldado Estoque',
    cpf: '55555555555',
    nivel_acesso: 1,
    id_setor: 1, // Almoxarifado
  },
  {
    email: 'soldadoFarmacia@eb.mil.br',
    password: '123456',
    nome: 'Soldado Farmácia',
    cpf: '66666666666',
    nivel_acesso: 1,
    id_setor: 2, // Farmácia
  },
  {
    email: 'soldadoOdonto@eb.mil.br',
    password: '123456',
    nome: 'Soldado Odonto',
    cpf: '77777777777',
    nivel_acesso: 1,
    id_setor: 3, // Odontologia
  },
  {
    email: 'soldadoComum@eb.mil.br',
    password: '123456',
    nome: 'Soldado Comum',
    cpf: '88888888888',
    nivel_acesso: 1,
    id_setor: 0, // Sem setor específico
  },
];

async function criarUsuarioComFoto(dadosUsuario) {
  console.log(`Criando usuário: ${dadosUsuario.nome} (${dadosUsuario.email})`);

  const dadosIniciaisUsuario = {
    email: dadosUsuario.email,
    password: dadosUsuario.password,
    email_confirm: true,
    user_metadata: {
      display_name: dadosUsuario.nome,
      cpf: dadosUsuario.cpf,
      nivel_acesso: dadosUsuario.nivel_acesso,
      id_setor: dadosUsuario.id_setor,
    }
  };

  console.log('Criando registro de autenticação do usuário...');
  const { data: userData, error: userError } = await supabase.auth.admin.createUser(dadosIniciaisUsuario);

  if (userError) {
    console.error(`Erro ao criar o usuário ${dadosUsuario.email}:`, userError.message);
    return false;
  }

  const novoUserId = userData.user.id;
  console.log(`Usuário ${dadosUsuario.email} criado com ID: ${novoUserId}`);

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

    console.log(`✅ Usuário ${dadosUsuario.email} criado com sucesso!`);
    return true;

  } catch (error) {
    console.error(`❌ Erro durante o upload da foto para ${dadosUsuario.email}:`, error.message);
    console.log('O usuário foi criado na autenticação, mas a foto falhou.');
    return false;
  }
}

async function criarTodosUsuarios() {
  console.log('🚀 Iniciando criação de todos os usuários de teste...\n');
  
  let sucessos = 0;
  let falhas = 0;

  for (const usuario of usuariosParaCriar) {
    console.log(`\n--- Criando ${usuario.nome} ---`);
    const sucesso = await criarUsuarioComFoto(usuario);
    
    if (sucesso) {
      sucessos++;
    } else {
      falhas++;
    }
    
    // Pequena pausa entre criações
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  console.log(`\n🎯 Resumo da criação:`);
  console.log(`✅ Sucessos: ${sucessos}`);
  console.log(`❌ Falhas: ${falhas}`);
  console.log(`📧 Total: ${usuariosParaCriar.length}`);
  
  console.log(`\n📋 Usuários criados:`);
  usuariosParaCriar.forEach(user => {
    console.log(`   • ${user.email} - ${user.nome} (Setor ${user.id_setor})`);
  });
}

criarTodosUsuarios();