<?php
// Recebe o texto (GET txt) e salva na tabela textos.
// Chamado pelo formulário de recebe.php e pelo app flutter_application_1.
$txt = $_GET['txt'];

$dsn = 'mysql:dbname=bancoBruno;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("INSERT INTO `textos` (`id`, `texto`) VALUES (NULL, :texto)");
$resultado = $sth->execute(['texto' => $txt]);

if($resultado) {
    echo "Texto salvo!";
} else {
    echo "Erro -> nao foi possivel salvar";
}
?>
