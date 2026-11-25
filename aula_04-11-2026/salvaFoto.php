<?php
// Recebe uma foto (POST multipart, campo "foto"), guarda em uploads/ e registra o caminho na tabela fotos.
// Chamado pelo formulário de recebeFoto.php e pelos apps fotos e fotos_galeria.
$foto = $_FILES['foto'] ?? null;

if (!$foto || $foto['error'] !== UPLOAD_ERR_OK) {
    echo "Erro -> foto nao recebida";
    exit;
}

$extensao = strtolower(pathinfo($foto['name'], PATHINFO_EXTENSION));
if (!in_array($extensao, ['jpg', 'jpeg', 'png'])) {
    echo "Erro -> formato invalido";
    exit;
}

$nome = uniqid() . '.' . $extensao;
$caminho = 'uploads/' . $nome;
move_uploaded_file($foto['tmp_name'], $caminho);

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("INSERT INTO `fotos` (`id`, `caminho`) VALUES (NULL, :caminho)");
$resultado = $sth->execute(['caminho' => $caminho]);

if($resultado) {
    echo "Foto salva! id=" . $dbh->lastInsertId();
} else {
    echo "Erro -> nao foi possivel salvar";
}
?>
