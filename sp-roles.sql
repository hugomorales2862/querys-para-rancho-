


CREATE PROCEDURE public.sysdbopen()
    DEFINE l_appname CHAR(128);
    
    SELECT TRIM(progname) INTO l_appname 
    FROM sysmaster:syssessions 
    WHERE sid = DBINFO('sessionid');

    -- Solo si NO es Aqua Data Studio
    IF (l_appname NOT LIKE '%aqua%' AND l_appname NOT LIKE '%ads%') THEN
        
        -- Activamos SOLO el rol maestro que contiene a todos los demás
        IF (EXISTS (SELECT 1 FROM informix.sysroleauth WHERE grantee = USER AND rolename = 'aplicacion_web')) THEN
            SET ROLE aplicacion_web;
        END IF;
        
    END IF;
END PROCEDURE;
