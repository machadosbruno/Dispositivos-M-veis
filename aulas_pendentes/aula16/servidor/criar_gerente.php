<?php
// Rode uma vez no terminal: php criar_gerente.php
// Cria o gerente pré-cadastrado: gerente@trufas.com / gerente123
$banco = new mysqli('localhost', 'root', '', 'aula16'); // ajuste usuário e senha

$nome = 'Gerente';
$email = 'gerente@trufas.com';
$senha = password_hash('gerente123', PASSWORD_DEFAULT);
$perfil = 'gerente';

$cmd = $banco->prepare('INSERT IGNORE INTO usuarios (nome, email, senha, perfil) VALUES (?, ?, ?, ?)');
$cmd->bind_param('ssss', $nome, $email, $senha, $perfil);
$cmd->execute();
echo "Gerente criado: $email / gerente123\n";
