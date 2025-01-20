CREATE DATABASE IF NOT EXISTS Ecommerce;
USE Ecommerce;

-- Tabela Cliente
CREATE TABLE IF NOT EXISTS Cliente (
    ClienteID INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Endereco VARCHAR(255),
    CPF CHAR(11),
    CNPJ VARCHAR(18),
    CONSTRAINT UC_Cliente_CPF UNIQUE (CPF),
    CONSTRAINT UC_Cliente_CNPJ UNIQUE (CNPJ),
    CONSTRAINT CK_Cliente_CPF_CNPJ CHECK (CPF IS NOT NULL OR CNPJ IS NOT NULL) -- Garante que pelo menos um seja preenchido
);

-- Tabela Produto
CREATE TABLE IF NOT EXISTS Produto (
    ProdutoID INT AUTO_INCREMENT PRIMARY KEY,
    Categoria VARCHAR(255),
    Descricao TEXT, -- Use TEXT para descrições maiores
    Valor DECIMAL(10, 2) -- Use DECIMAL para valores monetários
);

-- Tabela Pagamento
CREATE TABLE IF NOT EXISTS Pagamento (
    PagamentoID INT AUTO_INCREMENT PRIMARY KEY,
    ClienteID INT NOT NULL,
    TipoPagamento VARCHAR(50), -- Adicionado para melhor categorização (ex: Cartão, Boleto, Pix)
    NumeroCartao VARCHAR(20), -- Armazene apenas os últimos dígitos ou hash por segurança
    BandeiraCartao VARCHAR(50),
    DataPagamento DATETIME DEFAULT CURRENT_TIMESTAMP, -- Adiciona data e hora do pagamento
    CONSTRAINT FK_Pagamento_Cliente FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID)
);

-- Tabela Entrega
CREATE TABLE IF NOT EXISTS Entrega (
    EntregaID INT AUTO_INCREMENT PRIMARY KEY,
    PedidoID INT UNIQUE NOT NULL, -- Adicionado para relacionar diretamente com o pedido
    StatusEntrega VARCHAR(50) DEFAULT 'Pendente', -- Use VARCHAR para status mais descritivos
    CodigoRastreio VARCHAR(50),
    DataEntrega DATE,
    CONSTRAINT FK_Entrega_Pedido FOREIGN KEY (PedidoID) REFERENCES Pedido(PedidoID)
);

-- Tabela Pedido
CREATE TABLE IF NOT EXISTS Pedido (
    PedidoID INT AUTO_INCREMENT PRIMARY KEY,
    ClienteID INT NOT NULL,
    DataPedido DATETIME DEFAULT CURRENT_TIMESTAMP, -- Adiciona data e hora do pedido
    StatusPedido VARCHAR(50) DEFAULT 'Pendente', -- Use VARCHAR para status mais descritivos
    Frete DECIMAL(10, 2),
    Descricao TEXT,
    CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID)
);

-- Tabela Estoque
CREATE TABLE IF NOT EXISTS Estoque (
    EstoqueID INT AUTO_INCREMENT PRIMARY KEY,
    Local VARCHAR(255)
);

-- Tabela EstoqueProduto (Relacionamento entre Produto e Estoque)
CREATE TABLE IF NOT EXISTS EstoqueProduto (
    ProdutoID INT NOT NULL,
    EstoqueID INT NOT NULL,
    Quantidade INT DEFAULT 0, -- Quantidade não deve ser FLOAT, use INT
    PRIMARY KEY (ProdutoID, EstoqueID), -- Chave primária composta
    CONSTRAINT FK_EstoqueProduto_Produto FOREIGN KEY (ProdutoID) REFERENCES Produto(ProdutoID),
    CONSTRAINT FK_EstoqueProduto_Estoque FOREIGN KEY (EstoqueID) REFERENCES Estoque(EstoqueID)
);

-- Tabela Fornecedor
CREATE TABLE IF NOT EXISTS Fornecedor (
    FornecedorID INT AUTO_INCREMENT PRIMARY KEY,
    RazaoSocial VARCHAR(255),
    CPF CHAR(11),
    CNPJ VARCHAR(18),
    CONSTRAINT UC_Fornecedor_CPF UNIQUE (CPF),
    CONSTRAINT UC_Fornecedor_CNPJ UNIQUE (CNPJ),
    CONSTRAINT CK_Fornecedor_CPF_CNPJ CHECK (CPF IS NOT NULL OR CNPJ IS NOT NULL)
);

-- Tabela Terceiro (Mantive a tabela, mas considere se realmente precisa ser separada de Fornecedor)
CREATE TABLE IF NOT EXISTS Terceiro (
    TerceiroID INT AUTO_INCREMENT PRIMARY KEY,
    RazaoSocial VARCHAR(255),
    Localizacao VARCHAR(255),
    CPF CHAR(11),
    CNPJ VARCHAR(18),
    CONSTRAINT UC_Terceiro_CPF UNIQUE (CPF),
    CONSTRAINT UC_Terceiro_CNPJ UNIQUE (CNPJ),
    CONSTRAINT CK_Terceiro_CPF_CNPJ CHECK (CPF IS NOT NULL OR CNPJ IS NOT NULL)
);

-- Tabela PedidoProduto (Relacionamento entre Pedido e Produto)
CREATE TABLE IF NOT EXISTS PedidoProduto (
    PedidoID INT NOT NULL,
    ProdutoID INT NOT NULL,
    Quantidade INT DEFAULT 1,
    PRIMARY KEY (PedidoID, ProdutoID), -- Chave primária composta
    CONSTRAINT FK_PedidoProduto_Pedido FOREIGN KEY (PedidoID) REFERENCES Pedido(PedidoID),
    CONSTRAINT FK_PedidoProduto_Produto FOREIGN KEY (ProdutoID) REFERENCES Produto(ProdutoID)
);

-- Tabela PedidoFornecedor (Relacionamento entre Pedido e Fornecedor)
CREATE TABLE IF NOT EXISTS PedidoFornecedor (
    PedidoID INT NOT NULL,
    FornecedorID INT NOT NULL,
    Quantidade INT DEFAULT 1,
    PRIMARY KEY (PedidoID, FornecedorID), -- Chave primária composta
    CONSTRAINT FK_PedidoFornecedor_Fornecedor FOREIGN KEY (FornecedorID) REFERENCES Fornecedor(FornecedorID),
    CONSTRAINT FK_PedidoFornecedor_Pedido FOREIGN KEY (PedidoID) REFERENCES Pedido(PedidoID)
);

-- Tabelas EstoqueFornecedor e EstoqueTerceiro removidas. A relação já está implícita em PedidoFornecedor e pode ser consultada através das tabelas Produto e Fornecedor/Terceiro.

-- Adicionando índice para otimizar consultas frequentes
CREATE INDEX IDX_Pedido_ClienteID ON Pedido (ClienteID);
CREATE INDEX IDX_Pagamento_ClienteID ON Pagamento (ClienteID);
CREATE INDEX IDX_EstoqueProduto_ProdutoID ON EstoqueProduto (ProdutoID);
CREATE INDEX IDX_EstoqueProduto_EstoqueID ON EstoqueProduto (EstoqueID);
CREATE INDEX IDX_PedidoProduto_PedidoID ON PedidoProduto (PedidoID);
CREATE INDEX IDX_PedidoProduto_ProdutoID ON PedidoProduto (ProdutoID);
CREATE INDEX IDX_PedidoFornecedor_FornecedorID ON PedidoFornecedor (FornecedorID);
CREATE INDEX IDX_PedidoFornecedor_PedidoID ON PedidoFornecedor (PedidoID);