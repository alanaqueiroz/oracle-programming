DROP TABLE cliente CASCADE CONSTRAINTS;
DROP TABLE cliente_fisica CASCADE CONSTRAINTS;
DROP TABLE cliente_juridica CASCADE CONSTRAINTS;
DROP TABLE fabricante CASCADE CONSTRAINTS;
DROP TABLE modelo CASCADE CONSTRAINTS;
DROP TABLE veiculo CASCADE CONSTRAINTS;
DROP TABLE venda CASCADE CONSTRAINTS;
DROP TABLE versao CASCADE CONSTRAINTS;

CREATE TABLE cliente (
    id_cli       NUMBER(10) NOT NULL,
    nome_cliente VARCHAR2(120) NOT NULL,
    tipo         NUMBER(1) NOT NULL,
    endereco     VARCHAR2(120) NOT NULL,
    numero       VARCHAR2(10) NOT NULL,
    complemento  VARCHAR2(120),
    bairro       VARCHAR2(120) NOT NULL,
    cidade       VARCHAR2(120) NOT NULL,
    estado       CHAR(2) NOT NULL
);
 
ALTER TABLE cliente
    ADD CHECK ( tipo IN ( 1, 2 ) );
 
ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cli );
 
CREATE TABLE cliente_fisica (
    cliente_id_cli  NUMBER(10) NOT NULL PRIMARY KEY,
    cpf             CHAR(14) NOT NULL,
    "NOME COMPLETO" VARCHAR2(120) NOT NULL
);
 
CREATE UNIQUE INDEX cliente_fisica_cpf_idx ON
    cliente_fisica (
        cpf
    ASC );
 
CREATE TABLE cliente_juridica (
    cliente_id_cli     NUMBER(10) NOT NULL PRIMARY KEY,
    razao_social       VARCHAR2(120) NOT NULL,
    nome_fantasia      VARCHAR2(120) NOT NULL,
    cnpj               CHAR(18) NOT NULL,
    inscricao_estadual CHAR(15)
);
 
CREATE UNIQUE INDEX cliente_juridica_cnpj_idx ON
    cliente_juridica (
        cnpj
    ASC );
 
CREATE TABLE fabricante (
    id_fab  NUMBER(4) NOT NULL,
    nome    VARCHAR2(120) NOT NULL,
    apelido VARCHAR2(60)
);
 
CREATE UNIQUE INDEX fabricante_nome_idx ON
    fabricante (
        nome
    ASC );
 
ALTER TABLE fabricante ADD CONSTRAINT fabricante_pk PRIMARY KEY ( id_fab );
 
CREATE TABLE modelo (
    id_fab NUMBER(4) NOT NULL,
    id_mod NUMBER(5) NOT NULL,
    nome   VARCHAR2(120)
);
 
ALTER TABLE modelo ADD CONSTRAINT modelo_pk PRIMARY KEY ( id_mod,
                                                          id_fab );
 

CREATE TABLE veiculo (
    id_vei           NUMBER(10) NOT NULL,
    ano_fabricacao   NUMBER(4) NOT NULL,
    ano_modelo       NUMBER(4) NOT NULL,
    chassi           CHAR(17) NOT NULL,
    placa            CHAR(8),
    cor_predominante VARCHAR2(60) NOT NULL,
    id_fab           NUMBER(4) NOT NULL,
    id_mod           NUMBER(5) NOT NULL,
    id_ver           NUMBER(6) NOT NULL,
    preco_compra     NUMBER(12, 2) NOT NULL,
    preco_venda      NUMBER(12, 2) NOT NULL
);
 
CREATE UNIQUE INDEX veiculo_chassi_idx ON
    veiculo (
        chassi
    ASC );
 
ALTER TABLE veiculo ADD CONSTRAINT veiculo_pk PRIMARY KEY ( id_vei );
 
CREATE TABLE venda (
    id_vei      NUMBER(10) NOT NULL,
    id_cli      NUMBER(10) NOT NULL,
    data_venda  DATE NOT NULL,
    valor_venda NUMBER(12, 2) NOT NULL
);
 
ALTER TABLE venda ADD CONSTRAINT venda_pk PRIMARY KEY ( id_vei,
                                                        id_cli );
 
CREATE TABLE versao (
    id_fab NUMBER(4) NOT NULL,
    id_mod NUMBER(5) NOT NULL,
    id_ver NUMBER(6) NOT NULL,
    nome   VARCHAR2(120) NOT NULL
);
 
ALTER TABLE versao
    ADD CONSTRAINT versao_pk PRIMARY KEY ( id_ver,
                                           id_fab,
                                           id_mod );
 
ALTER TABLE cliente_fisica
    ADD CONSTRAINT cliente_fisica_cliente_fk FOREIGN KEY ( cliente_id_cli )
        REFERENCES cliente ( id_cli );
 
ALTER TABLE cliente_juridica
    ADD CONSTRAINT cliente_juridica_cliente_fk FOREIGN KEY ( cliente_id_cli )
        REFERENCES cliente ( id_cli );
 
ALTER TABLE modelo
    ADD CONSTRAINT modelo_fabricante_fk FOREIGN KEY ( id_fab )
        REFERENCES fabricante ( id_fab );
 
ALTER TABLE veiculo
    ADD CONSTRAINT veiculo_versao_fk FOREIGN KEY ( id_ver,
                                                   id_fab,
                                                   id_mod )
        REFERENCES versao ( id_ver,
                            id_fab,
                            id_mod );
 
ALTER TABLE venda
    ADD CONSTRAINT venda_cliente_fk FOREIGN KEY ( id_cli )
        REFERENCES cliente ( id_cli );
 
ALTER TABLE venda
    ADD CONSTRAINT venda_veiculo_fk FOREIGN KEY ( id_vei )
        REFERENCES veiculo ( id_vei );
 
ALTER TABLE versao
    ADD CONSTRAINT versao_modelo_fk FOREIGN KEY ( id_mod,
                                                  id_fab )
        REFERENCES modelo ( id_mod, id_fab );