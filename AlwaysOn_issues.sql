

--fisrt window failover cluster

    1.nodes maybe down
    2.quorum configuration
    3.network issues

--endpoint permission

--permission revoke maybe

--check the algorithm of endpoint

--we suspended the data movemet ( we have to resume the data movement means start)

--LSN miss match

-- version different also caused the not synchronized data( 2019 primary to sql server 2022)

--Servername, AG name ,and which database is suspended


	SELECT
    @@SERVERNAME AS CurrentServer,
    ag.name AS AGName,
    ar.replica_server_name,
    DB_NAME(drs.database_id) AS DatabaseName,
    drs.is_suspended,
    drs.suspend_reason_desc,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc
    FROM sys.dm_hadr_database_replica_states drs
    INNER JOIN sys.availability_replicas ar
    ON drs.replica_id = ar.replica_id
    INNER JOIN sys.availability_groups ag
    ON drs.group_id = ag.group_id
    ORDER BY ag.name, DatabaseName;


--check the which sql server on AG

     select @@VERSION
    

 ---check listener name and port,ip address

        SELECT
        dns_name AS ListenerName,
        port,
        ip_configuration_string_from_cluster
        FROM sys.availability_group_listeners;

 -- check the service account runing from which account 

       SELECT servicename, service_account
       FROM sys.dm_server_services

--- grant permission on end point

       GRANT CONNECT ON ENDPOINT::Hadr_endpoint
       TO [DOMAIN\SQLSvc];

--- endpoint name 


	SELECT
    e.name,
    e.state_desc,
    t.port
    FROM sys.endpoints e
    JOIN sys.tcp_endpoints t
    ON e.endpoint_id = t.endpoint_id
    WHERE e.type_desc = 'DATABASE_MIRRORING';


 --1. Check synchronization status

    Run on the primary replica:


    SELECT
    DB_NAME(database_id) AS DatabaseName,
    synchronization_state_desc,
    synchronization_health_desc,
    last_hardened_lsn,
    last_redone_lsn,
    recovery_lsn,
	last_sent_lsn,last_commit_time
    FROM sys.dm_hadr_database_replica_states
    ORDER BY DatabaseName;


--2. Compare primary and secondary LSNs

    Run on each replica:

    SELECT
    @@SERVERNAME AS ServerName,
    DB_NAME(database_id) AS DatabaseName,
    last_sent_lsn,
    last_received_lsn,
    last_hardened_lsn,
    last_redone_lsn
    FROM sys.dm_hadr_database_replica_states;


--3. Check AG dashboard information

    SELECT
    ar.replica_server_name,
    drs.database_id,
    DB_NAME(drs.database_id) AS DatabaseName,
    drs.synchronization_state_desc,
    drs.last_hardened_lsn,
    drs.last_redone_lsn
    FROM sys.dm_hadr_database_replica_states drs
    JOIN sys.availability_replicas ar
    ON drs.replica_id = ar.replica_id;

--4. Look for suspended data movement


    SELECT
    DB_NAME(database_id) AS DatabaseName,
    is_suspended,
    suspend_reason_desc
    FROM sys.dm_hadr_database_replica_states;

   If is_suspended = 1, note the suspend_reason_desc.


 