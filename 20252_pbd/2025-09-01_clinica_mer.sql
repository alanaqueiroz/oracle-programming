-- Gerado por Oracle SQL Developer Data Modeler 4.0.0.833
--   em:        2025-09-01 20:05:24 BRT
--   site:      Oracle Database 11g
--   tipo:      Oracle Database 11g




CREATE TABLE CONSULTA
  (
    crm             NUMBER NOT NULL ,
    id_pac          NUMBER NOT NULL ,
    dth_agendamento DATE NULL ,
    tipo            CHAR (1) NULL ,
    status          CHAR (1) NULL ,
    observacao      VARCHAR2 (512) NULL
  )
  ORGANIZATION HEAP NOCOMPRESS NOCACHE NOPARALLEL NOROWDEPENDENCIES DISABLE ROW MOVEMENT ;
ALTER TABLE CONSULTA ADD CHECK ( tipo   IN ('C', 'R'));
ALTER TABLE CONSULTA ADD CHECK ( status IN ('A', 'C', 'R'));
ALTER TABLE CONSULTA ADD CONSTRAINT CONSULTA_PK PRIMARY KEY ( crm, id_pac ) ;

CREATE TABLE ESPECIALIDADE
  (
    id_esp NUMBER NOT NULL ,
    nome   VARCHAR2 (120) NULL
  )
  ORGANIZATION HEAP NOCOMPRESS NOCACHE NOPARALLEL NOROWDEPENDENCIES DISABLE ROW MOVEMENT ;
ALTER TABLE ESPECIALIDADE ADD CONSTRAINT ESPECIALIDADE_PK PRIMARY KEY ( id_esp );

CREATE TABLE MEDICO
  (
    crm       NUMBER NOT NULL ,
    nome      VARCHAR2 (120) NULL ,
    data_nasc DATE NULL ,
    genero    CHAR (1) NULL ,
    id_esp    NUMBER NOT NULL
  )
  ORGANIZATION HEAP NOCOMPRESS NOCACHE NOPARALLEL NOROWDEPENDENCIES DISABLE ROW MOVEMENT ;
ALTER TABLE MEDICO ADD CHECK ( genero IN ('F', 'M')) NOT DEFERRABLE ENABLE VALIDATE ;
ALTER TABLE MEDICO ADD CONSTRAINT medico_PK PRIMARY KEY ( crm ) NOT DEFERRABLE ENABLE VALIDATE ;

CREATE TABLE PACIENTE
  (
    id_pac    NUMBER NOT NULL ,
    nome      VARCHAR2 (120) NULL ,
    data_nasc DATE NULL ,
    genero    CHAR (1) NULL ,
    cpf       CHAR (1) NULL
  )
  ORGANIZATION HEAP NOCOMPRESS NOCACHE NOPARALLEL NOROWDEPENDENCIES DISABLE ROW MOVEMENT ;
ALTER TABLE PACIENTE ADD CHECK ( genero IN ('F', 'M')) NOT DEFERRABLE ENABLE VALIDATE ;
ALTER TABLE PACIENTE ADD CONSTRAINT PACIENTE_PK PRIMARY KEY ( id_pac ) NOT DEFERRABLE ENABLE VALIDATE ;

ALTER TABLE CONSULTA ADD CONSTRAINT CONSULTA_MEDICO_FK FOREIGN KEY ( crm ) REFERENCES MEDICO ( crm ) ;

ALTER TABLE CONSULTA ADD CONSTRAINT CONSULTA_PACIENTE_FK FOREIGN KEY ( id_pac ) REFERENCES PACIENTE ( id_pac ) ;

ALTER TABLE MEDICO ADD CONSTRAINT MEDICO_ESPECIALIDADE_FK FOREIGN KEY ( id_esp ) REFERENCES ESPECIALIDADE ( id_esp ) ;


-- Relatório do Resumo do Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                             4
-- CREATE INDEX                             0
-- ALTER TABLE                             11
-- CREATE VIEW                              0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
