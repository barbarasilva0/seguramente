<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Recupera o idUsuario da sessão
    Integer idUsuario = null;
    if(session.getAttribute("idUsuario") != null) {
        try {
            idUsuario = Integer.parseInt(session.getAttribute("idUsuario").toString());
        } catch(Exception ex) {
            idUsuario = null;
        }
    }
    
    // Se o usuário não estiver logado, redireciona para login
    if(idUsuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int quizzesCompletados = 0;
    
    // Declarar variáveis para conexões e statements
    Connection connUtilizadores = null;
    Connection connJogos = null;
    Statement stmtUtilizadores = null;
    Statement stmtJogos = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        // Conexão com a base de dados de utilizadores
        connUtilizadores = DriverManager.getConnection("jdbc:mysql://localhost:3306/segura_utilizadores", "root", "!5xne5Qui8900");
        // Conexão com a base de dados de jogos (onde está a tabela Historico)
        connJogos = DriverManager.getConnection("jdbc:mysql://localhost:3306/segura_jogos", "root", "!5xne5Qui8900");
        
        stmtUtilizadores = connUtilizadores.createStatement();
        stmtJogos = connJogos.createStatement();
        
        // Contar quizzes completados pelo usuário (na tabela Historico da base segura_jogos)
        String countQuery = "SELECT COUNT(*) AS total FROM Historico WHERE ID_Utilizador = " + idUsuario + " AND Estado = 'Concluído'";
        ResultSet rsCount = stmtJogos.executeQuery(countQuery);
        if(rsCount.next()){
            quizzesCompletados = rsCount.getInt("total");
        }
        rsCount.close();
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(stmtUtilizadores != null) try { stmtUtilizadores.close(); } catch(Exception e) {}
        if(connUtilizadores != null) try { connUtilizadores.close(); } catch(Exception e) {}
        if(stmtJogos != null) try { stmtJogos.close(); } catch(Exception e) {}
        if(connJogos != null) try { connJogos.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Missões Semanais - SeguraMente</title>
    <link rel="stylesheet" href="html/css/missoes_semanais.css">
</head>
<body>
    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar">
            <h1>SeguraMente</h1>
            <a href="dashboard.jsp" class="sidebar-item">
                <img src="html/imagens/jogos_disponiveis_icon.png" alt="Jogos Disponíveis" style="width: 20px; height: 20px;">
                Jogos Disponíveis
            </a>
            <a href="missoes_semanais.jsp" class="sidebar-item">
                <img src="html/imagens/missoes_icon.png" alt="Missões Semanais" style="width: 20px; height: 20px;">
                Missões Semanais
            </a>
            <a href="historico.jsp" class="sidebar-item">
                <img src="html/imagens/historico_icon.png" alt="Histórico" style="width: 20px; height: 20px;">
                Histórico
            </a>
            <a href="logout.jsp" class="sidebar-item" id="logout">
                <img src="html/imagens/logout_icon.png" alt="Sair" style="width: 20px; height: 20px;">
                Sair
            </a>
        </div>

        <!-- Content -->
        <div class="content">
            <!-- Header -->
            <div class="header">
                <div class="search-container">
                    <img src="html/imagens/lupa.png" alt="Lupa" class="search-icon">
                    <input type="text" placeholder="Pesquisar...">
                </div>
                <a href="criar_quizz.jsp" class="create-quiz">Criar Quizz</a>
                <a href="perfil.jsp" class="profile">
                    <img src="html/imagens/avatar.png" alt="Avatar">
                    <!-- Exibe o nome do usuário (atributo definido no login.jsp) -->
                    <span><%= session.getAttribute("nomeUsuario") != null ? session.getAttribute("nomeUsuario") : "Pessoa" %></span>
                </a>
            </div>

            <!-- Quiz Section (Cabeçalho com informações do usuário) -->
            <div class="quiz-section">
                <div class="quiz-header">
                    <div class="user-info">
                        <img src="html/imagens/avatar.png" alt="Avatar do usuário" class="user-avatar">
                        <div class="user-details">
                            <span class="user-name"><%= session.getAttribute("nomeUsuario") != null ? session.getAttribute("nomeUsuario") : "Pessoa" %></span>
                            <div class="user-score-container">
                                <img src="html/imagens/flag_icon.png" alt="Flag Icon" class="flag-icon">
                                <div class="user-score">
                                    <span class="score-value"><%= quizzesCompletados %></span>
                                    <span class="score-text">Quiz Passed</span>
                                </div>
                            </div>
                        </div>                                            
                    </div>
                </div>
            </div>

            <!-- Missões Section -->
            <div class="missions-section">
                <div class="missions-header">Missões Semanais</div>
                <%
                    // Consulta para recuperar as missões do usuário a partir da base segura_jogos
                    Connection conn = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/segura_jogos", "root", "!5xne5Qui8900");
                        String query = "SELECT Nome, Progresso, Objetivo FROM Missao_Semanal WHERE ID_Utilizador = ?";
                        ps = conn.prepareStatement(query);
                        ps.setInt(1, idUsuario);
                        rs = ps.executeQuery();
                        while(rs.next()){
                            String missionName = rs.getString("Nome");
                            int progress = rs.getInt("Progresso");
                            String objective = rs.getString("Objetivo");
                %>
                                <div class="mission-card">
                                    <span><%= missionName %></span>
                                    <!-- Exibe o progresso e o objetivo da missão -->
                                    <span class="progress"><%= progress %> (<%= objective %>)</span>
                                </div>
                <%
                        }
                    } catch(Exception e) {
                        out.println("Erro ao carregar missões: " + e.getMessage());
                    } finally {
                        if(rs != null) try { rs.close(); } catch(Exception e) {}
                        if(ps != null) try { ps.close(); } catch(Exception e) {}
                        if(conn != null) try { conn.close(); } catch(Exception e) {}
                    }
                %>
            </div>
        </div>

        <!-- Modal de Logout -->
        <div class="modal-overlay" id="modal">
            <div class="modal-content">
                <h2>Tem certeza que deseja sair?</h2>
                <div class="modal-buttons">
                    <button class="btn-yes" id="confirmYes">Sim</button>
                    <button class="btn-no" id="confirmNo">Não</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        const logoutLink = document.getElementById('logout');
        const modal = document.getElementById('modal');
        const confirmYes = document.getElementById('confirmYes');
        const confirmNo = document.getElementById('confirmNo');

        logoutLink.addEventListener('click', (e) => {
            e.preventDefault();
            modal.classList.add('show');
        });

        confirmYes.addEventListener('click', () => {
            window.location.href = 'logout.jsp';
        });

        confirmNo.addEventListener('click', () => {
            modal.classList.remove('show');
        });
    </script>
</body>
</html>
