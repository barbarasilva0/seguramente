<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.Random" %>

<%
    // Conexão com o Banco de Dados
    String url = "jdbc:mysql://localhost:3306/segura";
    String user = "root"; // Substituir pelo usuário real do MySQL
    String password = "!5xne5Qui8900"; // Substituir pela senha real do MySQL
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    // Criando um PIN aleatório para o lobby
    Random rand = new Random();
    int pinLobby = 1000 + rand.nextInt(9000); // Gera um PIN entre 1000 e 9999

    // Obtendo o ID do quiz da URL
    String idJogo = request.getParameter("id");
    String tituloQuiz = "Quiz Desconhecido";
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, password);
        stmt = conn.createStatement();

        // Buscar o nome do quiz
        String query = "SELECT Nome FROM Jogo WHERE ID_Jogo = " + idJogo;
        rs = stmt.executeQuery(query);
        if (rs.next()) {
            tituloQuiz = rs.getString("Nome");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lobby do Quiz - <%= tituloQuiz %></title>
    <link rel="stylesheet" href="html/css/lobby.css">
</head>
<body>

    <!-- Cabeçalho fixo -->
    <header>
        <a href="dashboard.jsp" class="site-title">SeguraMente</a>
    </header>

    <!-- 🔔 Alerta personalizado -->
    <div id="custom-alert" class="custom-alert">Aguarde mais jogadores para iniciar o quiz!</div>

    <!-- Container principal -->
    <div class="container">
        <h1>Lobby do Quiz - <%= tituloQuiz %></h1>
        <div id="pin-display" class="pin-display">PIN: <%= pinLobby %></div>

        <button class="start-button" onclick="startQuiz()">Iniciar Quiz</button>

        <div class="players-container" id="players-container">
            <!-- Lista de jogadores em grade será adicionada aqui -->
        </div>
    </div>

	<script>
	    let players = []; // Lista de jogadores conectados
	
	    // Definição correta das variáveis para evitar o erro
	    const pinLobby = "<%= pinLobby %>"; 
	    const idJogo = "<%= idJogo %>"; 
	
	    function getNicknameFromUrl() {
	        const params = new URLSearchParams(window.location.search);
	        return params.get("nickname") || "Jogador Anônimo";
	    }
	
	    function addPlayer(nickname) {
	        if (!players.includes(nickname)) {
	            players.push(nickname);
	            updatePlayersList();
	        }
	    }
	
	    function updatePlayersList() {
	        const playersContainer = document.getElementById("players-container");
	        playersContainer.innerHTML = ""; 
	
	        players.forEach(player => {
	            let playerBox = document.createElement("div");
	            playerBox.classList.add("player-box");
	            playerBox.textContent = player;
	            playersContainer.appendChild(playerBox);
	        });
	    }
	
	    function startQuiz() {
	        if (players.length > 1) {
	            // Passamos diretamente as variáveis JS na URL sem encodeURIComponent no JSP
	            window.location.href = "quizz.jsp?id=" + encodeURIComponent(idJogo) + "&pin=" + encodeURIComponent(pinLobby);
	        } else {
	            showAlert("Aguarde mais jogadores para iniciar o quiz!");
	        }
	    }
	
	    // 🔔 Função para exibir o alerta estilizado
	    function showAlert(message) {
	        const alertBox = document.getElementById("custom-alert");
	        alertBox.textContent = message;
	        alertBox.style.display = "block";
	        setTimeout(() => {
	            alertBox.style.display = "none";
	        }, 3000);
	    }
	
	    // Inicializa a página
	    addPlayer(getNicknameFromUrl());
	</script>

</body>
</html>
