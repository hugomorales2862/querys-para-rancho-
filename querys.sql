----CON VISTAS
create view vista_ejecito_total_despacho (
clases,
promocion,
catalogo,
clase,
grado,
arma,
fuerza,
nombre,
fecha_nombramiento,
desc_empleo,
empleo,
dependencia,
plaza,
grado_rec_puesto,
years_puesto,
meses_puesto,
dias_puesto,
prox_ascenso,
ultimo_ascenso_individual,
tiempo_como_oficial,
sexo,
ult_asc_mas_comun_promo,
perfil_biofisico,
tiempo_postergacion,
situacion
)AS
SELECT 
   g.gra_clase as clases,
   p.per_promocion AS promocion,
   p.per_catalogo AS catalogo,
   cast(
   CASE
        WHEN g.gra_clase = 1 THEN 'OFICIAL'
        WHEN g.gra_clase = 2 THEN 'OFICIAL'
        WHEN g.gra_clase = 3 THEN 'OFICIAL ASIMILADO'     
        WHEN g.gra_clase = 4 THEN 'ESPECIALISTA'
        WHEN g.gra_clase = 5 THEN 'CADETE'
        WHEN g.gra_clase = 6 THEN 'TROPA'
    END 
    as varchar(50)) AS clase,
    g.gra_desc_md AS grado,
    a.arm_desc_md AS arma,
    cast (
    case   
when g.gra_clase = 1 and a.arm_codigo IN (5,7)
then 'FUERZA DE AIRE'
when g.gra_clase = 1 and a.arm_codigo IN (6)
then 'FUERZA DE MAR'
when g.gra_clase IN (1,2) and a.arm_codigo NOT IN (5,6,7)
then 'FUERZA DE TIERRA'
when g.gra_clase IN (3,4,6) and o.org_dependencia   IN (2340,2610,2620,2630,2700,2730,4030)
then 'FUERZA DE MAR'
when g.gra_clase IN (3,4,6) and o.org_dependencia   IN (2320,2330,2510,2560,2580,2590,2600)
then 'FUERZA DE AIRE'
when g.gra_clase IN (3,4,6) and o.org_dependencia   NOT IN (2320,2330,2510,2560,2580,2590,2600,2340,2610,2620,2630,2700,2730,4030)
then 'FUERZA DE TIERRA'
when g.gra_clase = 5 
then 'FUERZA DE TIERRA'
 end
  as varchar(50))as FUERZA,
    TRIM(p.per_ape1) || ' ' || TRIM(p.per_ape2) || ', ' || TRIM(p.per_nom1) AS nombre,
    p.per_fec_nomb AS fecha_nombramiento,
    p.per_desc_empleo AS desc_empleo,
    o.org_plaza_desc AS empleo,
    d.dep_desc_md AS dependencia,
    p.per_plaza AS plaza,
    g2.gra_desc_lg AS grado_rec_puesto,
  cast(SUBSTR(LPAD(t.t_puesto, 6, '0'), 1, 2)as char (2)) AS years_puesto,
   cast(SUBSTR(LPAD(t.t_puesto, 6, '0'), 3, 2)as char (2)) AS meses_puesto,
    cast(SUBSTR(LPAD(t.t_puesto, 6, '0'), 5, 2)as char (2)) AS dias_puesto,
   t.t_prox_asc AS prox_ascenso,
    t.t_ult_asc AS ultimo_ascenso_individual,
   cast(   TRIM(
        TRUNC(t.t_esp_ofi / 10000) || ' años ' ||
        TRUNC(MOD(t.t_esp_ofi, 10000) / 100) || ' meses ' ||
        MOD(t.t_esp_ofi, 100) || ' días'
    ) as varchar (50))AS tiempo_como_oficial,
    p.per_sexo AS sexo,
    cast (pmf.ult_asc_mas_comun as date )AS ult_asc_mas_comun_promo,
    cast(CASE 
        WHEN ev.e_diagnost = 1 THEN 'DEFICIT'
        WHEN ev.e_diagnost = 2 THEN 'NORMAL'
        WHEN ev.e_diagnost = 3 THEN 'SOBREPESO'
        WHEN ev.e_diagnost = 4 THEN 'OBESIDAD'
        ELSE 'SIN DIAGNOSTICO'
    END
    as varchar(50)) AS perfil_biofisico,
cast(CASE
   WHEN (YEAR(t.t_ult_asc) = YEAR(pmf.ult_asc_mas_comun) - 1 AND MONTH(t.t_ult_asc) >= 7 and g.gra_clase = 1)
          or (YEAR(t.t_ult_asc) = YEAR(pmf.ult_asc_mas_comun) + 5 AND MONTH(t.t_ult_asc) >= 7  and g.gra_clase = 1)          
          or (YEAR(t.t_ult_asc) = YEAR(pmf.ult_asc_mas_comun) + 4 AND MONTH(t.t_ult_asc) >= 7  and g.gra_clase = 1)
          or (per_catalogo in (668376,668285,668301,668368,668442))
    THEN '0 años 0 meses '
             
     WHEN pmf.ult_asc_mas_comun < t.t_ult_asc  and  g.gra_codigo not in (93,97)
     
     THEN
       TRUNC((t.t_ult_asc - pmf.ult_asc_mas_comun ) / 365) || ' años ' ||
         TRUNC(MOD((t.t_ult_asc - pmf.ult_asc_mas_comun), 365) / 30) || ' meses '
  
   WHEN pmf.ult_asc_mas_comun > t.t_ult_asc  and  g.gra_codigo not in (93,97,41) and YEAR(pmf.ult_asc_mas_comun) != YEAR(t.t_ult_asc) 
   THEN 
           TRUNC(( pmf.ult_asc_mas_comun - t.t_ult_asc ) / 365) || ' años ' ||
         TRUNC(MOD(( pmf.ult_asc_mas_comun - t.t_ult_asc), 365) / 30) || ' meses '
         
     WHEN pmf.ult_asc_mas_comun > t.t_ult_asc  and  g.gra_codigo not in (93,97) and YEAR(pmf.ult_asc_mas_comun) != YEAR(t.t_ult_asc) and g.gra_codigo = 41
   
   THEN
     TRUNC((TODAY - pmf.ult_asc_mas_comun::DATE ) / 365) || ' años ' ||
       TRUNC(MOD((TODAY - pmf.ult_asc_mas_comun::DATE ), 365) / 30) || ' meses '
       
    WHEN pmf.ult_asc_mas_comun > t.t_ult_asc  and  g.gra_codigo not in (93,97) and YEAR(pmf.ult_asc_mas_comun) = YEAR(t.t_ult_asc)  
        THEN
             TRUNC(ABS(pmf.ult_asc_mas_comun - t.t_ult_asc) / 365) || ' años ' ||
            TRUNC(MOD(ABS(pmf.ult_asc_mas_comun - t.t_ult_asc), 365) / 30) || ' meses '

  
         
    WHEN pmf.ult_asc_mas_comun = t.t_ult_asc  and  g.gra_codigo not in (93,97)
        THEN
       '0 años 0 meses '
    WHEN pmf.ult_asc_mas_comun < t.t_ult_asc  and  g.gra_codigo in (93,97)
      THEN
      '0 años 0 meses '

END
as varchar(50))AS tiempo_postergacion,
sit.sit_desc_lg as situacion


FROM
    mper p
    JOIN grados g ON p.per_grado = g.gra_codigo
    JOIN armas a ON p.per_arma = a.arm_codigo
    JOIN morg o ON p.per_plaza = o.org_plaza
    JOIN grados g2 ON g2.gra_codigo = o.org_grado
    JOIN mdep d ON d.dep_llave = o.org_dependencia
    JOIN situaciones sit ON p.per_situacion = sit.sit_codigo 
    JOIN tiempos t ON t.t_catalogo = p.per_catalogo
     LEFT JOIN evaluaciones ev ON p.per_catalogo = ev.e_catalogo
        AND ev.e_evaluacion = (
            SELECT MAX(e2.e_evaluacion)
            FROM evaluaciones e2
            WHERE e2.e_catalogo = p.per_catalogo
        )
        AND ev.e_numero = (
            SELECT MAX(e2.e_numero)
            FROM evaluaciones e2
            WHERE e2.e_catalogo = p.per_catalogo
              AND e2.e_evaluacion = ev.e_evaluacion
        )
  
 
   LEFT JOIN (
    SELECT   
        per_promocion,
        CASE 
            WHEN per_promocion = 10  THEN DATE('2016-01-01') 
            WHEN per_promocion = 116 THEN DATE('2013-07-01') 
            WHEN per_promocion = 117 THEN DATE('2014-01-01')
            WHEN per_promocion = 120 THEN DATE('2015-07-01')
            WHEN per_promocion = 126 THEN DATE('2019-07-01')       
            ELSE t_ult_asc
        END AS ult_asc_mas_comun
    FROM (
        SELECT per_promocion,
               t_ult_asc,
               t_grado,
               cantidad,
               ROW_NUMBER() OVER (
                   PARTITION BY per_promocion 
                   ORDER BY cantidad DESC, t_ult_asc ASC, t_grado DESC
               ) AS rn
        FROM (
            SELECT p_in.per_promocion,
                   t_in.t_ult_asc,
                   MAX(t_in.t_grado) AS t_grado,
                   COUNT(*) AS cantidad
            FROM mper p_in
            JOIN tiempos t_in ON p_in.per_catalogo = t_in.t_catalogo
            WHERE p_in.per_promocion != 0
            GROUP BY p_in.per_promocion, t_in.t_ult_asc
        ) AS sub_in
    ) AS sub_out
    WHERE rn = 1
) pmf 
    ON p.per_promocion = pmf.per_promocion
WHERE
    g.gra_clase IN (1, 2, 3, 4, 5, 6)
  and p.per_situacion in ('TH','1L','1P','1$','2N','TJ','2K','2J',11,'T0')

union all 

SELECT 
   gra_clase AS clases,
   CAST(NULL AS INTEGER) AS promocion,
   per_catalogo AS catalogo,
    cast(
        CASE
        WHEN gra_clase = 1 THEN 'OFICIALES CARRERA'
        WHEN gra_clase = 2 THEN 'OFICIALES RESERVA'
        WHEN gra_clase = 3 THEN 'OFICIALES ASIMILADOS'     
        WHEN gra_clase = 4 THEN 'ESPECIALISTAS'
        WHEN gra_clase = 5 THEN 'CADETES'
        WHEN gra_clase = 6 THEN 'TROPA'
    END
     as varchar(50)) AS clase,
   gra_desc_lg AS grado,
   CAST(NULL AS CHAR(15)) AS arma,
   CAST(NULL AS VARCHAR(50)) AS fuerza,
   TRIM(per_ape1) || ' ' || TRIM(per_ape2) || ', ' || TRIM(per_nom1) AS nombre,
   CAST(NULL AS DATE) AS fecha_nombramiento,
   per_desc_empleo AS desc_empleo,
   org_plaza_desc AS empleo,
   dep_desc_md AS dependencia,
   org_plaza AS plaza,
   CAST(NULL AS CHAR(30)) AS grado_rec_puesto,
   CAST(NULL AS CHAR(2)) AS years_puesto,
   CAST(NULL AS CHAR(2)) AS meses_puesto,
   CAST(NULL AS CHAR(2)) AS dias_puesto,
   CAST(NULL AS char(10)) AS prox_ascenso,
   CAST(NULL AS DATE) AS ultimo_ascenso_individual,
   CAST(NULL AS VARCHAR(50)) AS tiempo_como_oficial,
   CAST(NULL AS CHAR(1)) AS sexo,
   CAST(NULL AS DATE) AS ult_asc_mas_comun_promo,
   CAST(NULL AS VARCHAR(50)) AS perfil_biofisico,
   CAST(NULL AS VARCHAR(50)) AS tiempo_postergacion,
   CAST(NULL AS char(40)) AS situacion
FROM 
    morg
LEFT JOIN 
    mper ON org_plaza = per_plaza
LEFT JOIN 
    grados ON org_grado = gra_codigo
LEFT JOIN 
    mdep ON dep_llave = org_dependencia
WHERE 
    per_plaza IS NULL 
    AND org_situacion = 'A' 
    AND org_ceom != 'TITULO'
    AND gra_clase in (1,2,3,4,6)
ORDER BY clases ASC, promocion ASC NULLS LAST;

    

----------------SIN MIN PUESTOS


  SELECT 
   g.gra_clase as clases,
   p.per_promocion AS promocion,
   p.per_catalogo AS catalogo,
   (CASE
        WHEN g.gra_clase = 1 THEN 'OFICIAL'
        WHEN g.gra_clase = 2 THEN 'OFICIAL'
        WHEN g.gra_clase = 3 THEN 'OFICIAL ASIMILADO'     
        WHEN g.gra_clase = 4 THEN 'ESPECIALISTA'
        WHEN g.gra_clase = 5 THEN 'CADETE'
        WHEN g.gra_clase = 6 THEN 'TROPA'
    END) AS clase,
    g.gra_desc_md AS grado,
    a.arm_desc_md AS arma,
    TRIM(p.per_ape1) || ' ' || TRIM(p.per_ape2) || ', ' || TRIM(p.per_nom1) AS nombre,
    p.per_fec_nomb AS fecha_nombramiento,
    p.per_desc_empleo AS desc_empleo,
    o.org_plaza_desc AS empleo,
    d.dep_desc_md AS dependencia,
    p.per_plaza AS plaza,
    g2.gra_desc_lg AS grado_rec_puesto,
    SUBSTR(LPAD(t.t_puesto, 6, '0'), 1, 2) AS years_puesto,
    SUBSTR(LPAD(t.t_puesto, 6, '0'), 3, 2) AS meses_puesto,
    SUBSTR(LPAD(t.t_puesto, 6, '0'), 5, 2) AS dias_puesto,
    t.t_prox_asc AS prox_ascenso,
    t.t_ult_asc AS ultimo_ascenso_individual,
      TRIM(
        TRUNC(t.t_esp_ofi / 10000) || ' años ' ||
        TRUNC(MOD(t.t_esp_ofi, 10000) / 100) || ' meses ' ||
        MOD(t.t_esp_ofi, 100) || ' días'
    ) AS tiempo_como_oficial,
    p.per_sexo AS sexo,
    pmf.ult_asc_mas_comun AS ult_asc_mas_comun_promo,
    (CASE 
        WHEN ev.e_diagnost = 1 THEN 'DEFICIT'
        WHEN ev.e_diagnost = 2 THEN 'NORMAL'
        WHEN ev.e_diagnost = 3 THEN 'SOBREPESO'
        WHEN ev.e_diagnost = 4 THEN 'OBESIDAD'
        ELSE 'SIN DIAGNOSTICO'
    END) AS perfil_biofisico,
(CASE
   WHEN (YEAR(t.t_ult_asc) = YEAR(pmf.ult_asc_mas_comun) - 1 AND MONTH(t.t_ult_asc) >= 7 and g.gra_clase = 1)
          or (YEAR(t.t_ult_asc) = YEAR(pmf.ult_asc_mas_comun) + 5 AND MONTH(t.t_ult_asc) >= 7  and g.gra_clase = 1)          
          or (YEAR(t.t_ult_asc) = YEAR(pmf.ult_asc_mas_comun) + 4 AND MONTH(t.t_ult_asc) >= 7  and g.gra_clase = 1)
          or (per_catalogo in (668376,668285,668301,668368,668442))
    THEN '0 años 0 meses '
             
     WHEN pmf.ult_asc_mas_comun < t.t_ult_asc  and  g.gra_codigo not in (93,97)
     
     THEN
       TRUNC((t.t_ult_asc - pmf.ult_asc_mas_comun ) / 365) || ' años ' ||
         TRUNC(MOD((t.t_ult_asc - pmf.ult_asc_mas_comun), 365) / 30) || ' meses '
  
   WHEN pmf.ult_asc_mas_comun > t.t_ult_asc  and  g.gra_codigo not in (93,97,41) and YEAR(pmf.ult_asc_mas_comun) != YEAR(t.t_ult_asc) 
   THEN 
           TRUNC(( pmf.ult_asc_mas_comun - t.t_ult_asc ) / 365) || ' años ' ||
         TRUNC(MOD(( pmf.ult_asc_mas_comun - t.t_ult_asc), 365) / 30) || ' meses '
         
     WHEN pmf.ult_asc_mas_comun > t.t_ult_asc  and  g.gra_codigo not in (93,97) and YEAR(pmf.ult_asc_mas_comun) != YEAR(t.t_ult_asc) and g.gra_codigo = 41
   
   THEN
     TRUNC((TODAY - pmf.ult_asc_mas_comun::DATE ) / 365) || ' años ' ||
       TRUNC(MOD((TODAY - pmf.ult_asc_mas_comun::DATE ), 365) / 30) || ' meses '
       
    WHEN pmf.ult_asc_mas_comun > t.t_ult_asc  and  g.gra_codigo not in (93,97) and YEAR(pmf.ult_asc_mas_comun) = YEAR(t.t_ult_asc)  
        THEN
             TRUNC(ABS(pmf.ult_asc_mas_comun - t.t_ult_asc) / 365) || ' años ' ||
            TRUNC(MOD(ABS(pmf.ult_asc_mas_comun - t.t_ult_asc), 365) / 30) || ' meses '

  
         
    WHEN pmf.ult_asc_mas_comun = t.t_ult_asc  and  g.gra_codigo not in (93,97)
        THEN
       '0 años 0 meses '
    WHEN pmf.ult_asc_mas_comun < t.t_ult_asc  and  g.gra_codigo in (93,97)
      THEN
      '0 años 0 meses '

END)AS tiempo_postergacion,sit.sit_desc_lg as situacion,
--arm_codigo,
(case   
when g.gra_clase = 1 and a.arm_codigo IN (5,7)
then 'FUERZA DE AIRE'
when g.gra_clase = 1 and a.arm_codigo IN (6)
then 'FUERZA DE MAR'
when g.gra_clase IN (1,2) and a.arm_codigo NOT IN (5,6,7)
then 'FUERZA DE TIERRA'
when g.gra_clase IN (3,4,6) and o.org_dependencia   IN (2340,2610,2620,2630,2700,2730,4030)
then 'FUERZA DE MAR'
when g.gra_clase IN (3,4,6) and o.org_dependencia   IN (2320,2330,2510,2560,2580,2590,2600)
then 'FUERZA DE AIRE'
when g.gra_clase IN (3,4,6) and o.org_dependencia   NOT IN (2320,2330,2510,2560,2580,2590,2600,2340,2610,2620,2630,2700,2730,4030)
then 'FUERZA DE TIERRA'
when g.gra_clase = 5 
then 'FUERZA DE TIERRA'
 end )FUERZA


FROM
    mper p
    JOIN grados g ON p.per_grado = g.gra_codigo
    JOIN armas a ON p.per_arma = a.arm_codigo
    JOIN morg o ON p.per_plaza = o.org_plaza
    JOIN grados g2 ON g2.gra_codigo = o.org_grado
    JOIN mdep d ON d.dep_llave = o.org_dependencia
    JOIN situaciones sit ON p.per_situacion = sit.sit_codigo 
    JOIN tiempos t ON t.t_catalogo = p.per_catalogo
     LEFT JOIN evaluaciones ev ON p.per_catalogo = ev.e_catalogo
        AND ev.e_evaluacion = (
            SELECT MAX(e2.e_evaluacion)
            FROM evaluaciones e2
            WHERE e2.e_catalogo = p.per_catalogo
        )
        AND ev.e_numero = (
            SELECT MAX(e2.e_numero)
            FROM evaluaciones e2
            WHERE e2.e_catalogo = p.per_catalogo
              AND e2.e_evaluacion = ev.e_evaluacion
        )
  
      //  AND ev.e_numero = (
        //    SELECT MAX(e2.e_numero)
          //  FROM evaluaciones e2
           // WHERE e2.e_catalogo = p.per_catalogo
            //  AND e2.e_evaluacion = ev.e_evaluacion
       // )
   LEFT JOIN (
    SELECT   
        per_promocion,
        CASE 
            WHEN per_promocion = 10  THEN DATE('2016-01-01') 
            WHEN per_promocion = 116 THEN DATE('2013-07-01') 
            WHEN per_promocion = 117 THEN DATE('2014-01-01')
            WHEN per_promocion = 120 THEN DATE('2015-07-01')
            WHEN per_promocion = 126 THEN DATE('2019-07-01')       
            ELSE t_ult_asc
        END AS ult_asc_mas_comun
    FROM (
        SELECT per_promocion,
               t_ult_asc,
               t_grado,
               cantidad,
               ROW_NUMBER() OVER (
                   PARTITION BY per_promocion 
                   ORDER BY cantidad DESC, t_ult_asc ASC, t_grado DESC
               ) AS rn
        FROM (
            SELECT p_in.per_promocion,
                   t_in.t_ult_asc,
                   MAX(t_in.t_grado) AS t_grado,
                   COUNT(*) AS cantidad
            FROM mper p_in
            JOIN tiempos t_in ON p_in.per_catalogo = t_in.t_catalogo
            WHERE p_in.per_promocion != 0
            GROUP BY p_in.per_promocion, t_in.t_ult_asc
        ) AS sub_in
    ) AS sub_out
    WHERE rn = 1
) pmf 
    ON p.per_promocion = pmf.per_promocion
WHERE
    g.gra_clase IN (1, 2, 3, 4, 5, 6)
  and p.per_situacion in ('TH','1L','1P','1$','2N','TJ','2K','2J',11,'T0')
//and p.per_catalogo in (503202)
//668236)
//and p.per_catalogo in (650739,
//668236)
//668285,
//668301,
//668368,
//668442)
//and (pmf.ult_asc_mas_comun > t.t_ult_asc) 
ORDER BY clases ASC, promocion ASC;



------------------------------------------------------
-------------------------- CON MIN PUESTOS---------






SELECT
    p.per_promocion AS promocion,g.gra_clase as clases,
    p.per_catalogo AS catalogo,
    (CASE
        WHEN g.gra_clase = 1 THEN 'OFICIAL'
        WHEN g.gra_clase = 2 THEN 'OFICIAL'
        WHEN g.gra_clase = 3 THEN 'OFICIAL ASIMILADO'     
        WHEN g.gra_clase = 4 THEN 'ESPECIALISTA'
        WHEN g.gra_clase = 5 THEN 'CADETE'
        WHEN g.gra_clase = 6 THEN 'TROPA'
    END) AS clase,
    g.gra_desc_md AS grado,
    a.arm_desc_md AS arma,
    TRIM(p.per_ape1) || ' ' || TRIM(p.per_ape2) || ', ' || TRIM(p.per_nom1) AS nombre,
    p.per_fec_nomb AS fecha_nombramiento,
    p.per_desc_empleo AS desc_empleo,
    pu.puesto_nombre AS empleo,
    d.dep_desc_md AS dependencia,
    p.per_plaza AS plaza,
    g2.gra_desc_lg AS grado_rec_puesto,
    SUBSTR(LPAD(t.t_puesto, 6, '0'), 1, 2) AS years_puesto,
    SUBSTR(LPAD(t.t_puesto, 6, '0'), 3, 2) AS meses_puesto,
    SUBSTR(LPAD(t.t_puesto, 6, '0'), 5, 2) AS dias_puesto,
    t.t_prox_asc AS prox_ascenso,
    t.t_ult_asc AS ultimo_ascenso_individual,
    TRIM(
        TRUNC(t.t_esp_ofi / 10000) || ' años ' ||
        TRUNC(MOD(t.t_esp_ofi, 10000) / 100) || ' meses ' ||
        MOD(t.t_esp_ofi, 100) || ' días'
    ) AS tiempo_como_oficial,
    p.per_sexo AS sexo,
    -- === COLUMNA AÑADIDA DESDE LA SUBCONSULTA ===
    pmf.ult_asc_mas_comun AS ult_asc_mas_comun_promo,
  (case when e_diagnost =1      then 'DEFICIT'
           WHEN e_diagnost=2        THEN 'NORMAL'
                WHEN e_diagnost=3        THEN 'SOBREPESO'
              WHEN e_diagnost=4        THEN 'OBESIDAD' end)  as perfil_biofisico,
TRUNC(
    CASE
        WHEN pmf.ult_asc_mas_comun >= t.t_ult_asc
            THEN (pmf.ult_asc_mas_comun - t.t_ult_asc) / 365
        ELSE (t.t_ult_asc - pmf.ult_asc_mas_comun) / 365
    END
) || ' años ' ||
TRUNC(
    MOD(
        CASE
            WHEN pmf.ult_asc_mas_comun >= t.t_ult_asc
                THEN pmf.ult_asc_mas_comun - t.t_ult_asc
            ELSE t.t_ult_asc - pmf.ult_asc_mas_comun
        END, 365
    ) / 30
) || ' meses ' ||
MOD(
    CASE
        WHEN pmf.ult_asc_mas_comun >= t.t_ult_asc
            THEN pmf.ult_asc_mas_comun - t.t_ult_asc
        ELSE t.t_ult_asc - pmf.ult_asc_mas_comun
    END, 30
) || ' días' AS tiempo_postergacion


FROM
    mper p,
    grados g,
    armas a,
    morg o,
    grados g2,
    mdep d,
    min_unidades_organizacion muo,
    min_puestos pu,
    tiempos t,
  evaluaciones ev,
    -- === SUBCONSULTA UNIDA CON LEFT JOIN ===
    OUTER (
        SELECT
            counts.per_promocion,
            MIN(counts.t_ult_asc) AS ult_asc_mas_comun -- Usamos MIN para desempatar
        FROM
            (
                SELECT
                    p_in.per_promocion,
                    t_in.t_ult_asc,
                    COUNT(*) AS cantidad
                FROM mper p_in, tiempos t_in
                WHERE p_in.per_catalogo = t_in.t_catalogo
                  AND p_in.per_promocion != 0
                GROUP BY 1, 2
            ) AS counts,
            (
                SELECT
                    max_c.per_promocion,
                    MAX(max_c.cantidad) AS max_cantidad
                FROM
                    (
                        SELECT
                            p_in2.per_promocion,
                            t_in2.t_ult_asc,
                            COUNT(*) AS cantidad
                        FROM mper p_in2, tiempos t_in2
                        WHERE p_in2.per_catalogo = t_in2.t_catalogo
                          AND p_in2.per_promocion != 0
                        GROUP BY 1, 2
                    ) AS max_c
                GROUP BY 1
            ) AS max_vals
        WHERE
            counts.per_promocion = max_vals.per_promocion
            AND counts.cantidad = max_vals.max_cantidad
        GROUP BY 1
    ) AS pmf
WHERE
    p.per_grado = g.gra_codigo
    AND p.per_arma = a.arm_codigo
    AND p.per_plaza = o.org_plaza
    AND g2.gra_codigo = o.org_grado
    AND d.dep_llave = o.org_dependencia
    AND muo.orgn_plaza = o.org_plaza
    AND pu.puesto_id = muo.orgn_puesto
    AND t.t_catalogo = p.per_catalogo
    AND p.per_promocion = pmf.per_promocion
  AND p.per_catalogo = ev.e_catalogo
    AND g.gra_clase IN (1, 2, 3, 4, 5, 6)
  AND p.per_situacion IN ('TH','1L','1P','1$','2N','TJ','2K','2J',11,'T0')
ORDER BY clases asc , promocion asc;


---este tiene min unidades pero no esta bien 

    
    
    SELECT 
   g.gra_clase as clases,
   p.per_promocion AS promocion,
   p.per_catalogo AS catalogo,
   (CASE
        WHEN g.gra_clase = 1 THEN 'OFICIAL'
        WHEN g.gra_clase = 2 THEN 'OFICIAL'
        WHEN g.gra_clase = 3 THEN 'OFICIAL ASIMILADO'     
        WHEN g.gra_clase = 4 THEN 'ESPECIALISTA'
        WHEN g.gra_clase = 5 THEN 'CADETE'
        WHEN g.gra_clase = 6 THEN 'TROPA'
    END) AS clase,
    g.gra_desc_md AS grado,
    a.arm_desc_md AS arma,
    TRIM(p.per_ape1) || ' ' || TRIM(p.per_ape2) || ', ' || TRIM(p.per_nom1) AS nombre,
    p.per_fec_nomb AS fecha_nombramiento,
    p.per_desc_empleo AS desc_empleo,
    pu.puesto_nombre AS empleo,
    d.dep_desc_md AS dependencia,
    p.per_plaza AS plaza,
    g2.gra_desc_lg AS grado_rec_puesto,
    SUBSTR(LPAD(t.t_puesto, 6, '0'), 1, 2) AS years_puesto,
    SUBSTR(LPAD(t.t_puesto, 6, '0'), 3, 2) AS meses_puesto,
    SUBSTR(LPAD(t.t_puesto, 6, '0'), 5, 2) AS dias_puesto,
    t.t_prox_asc AS prox_ascenso,
    t.t_ult_asc AS ultimo_ascenso_individual,
    TRIM(
        TRUNC(t.t_esp_ofi / 10000) || ' años ' ||
        TRUNC(MOD(t.t_esp_ofi, 10000) / 100) || ' meses ' ||
        MOD(t.t_esp_ofi, 100) || ' días'
    ) AS tiempo_como_oficial,
    p.per_sexo AS sexo,
    pmf.ult_asc_mas_comun AS ult_asc_mas_comun_promo,
    (CASE 
        WHEN ev.e_diagnost = 1 THEN 'DEFICIT'
        WHEN ev.e_diagnost = 2 THEN 'NORMAL'
        WHEN ev.e_diagnost = 3 THEN 'SOBREPESO'
        WHEN ev.e_diagnost = 4 THEN 'OBESIDAD'
        ELSE 'SIN DIAGNOSTICO'
    END) AS perfil_biofisico,
    TRUNC((pmf.ult_asc_mas_comun - t.t_ult_asc) / 365) || ' años ' ||
TRUNC(MOD((pmf.ult_asc_mas_comun - t.t_ult_asc), 365) / 30) || ' meses ' ||
MOD((pmf.ult_asc_mas_comun - t.t_ult_asc), 30) || ' días' AS tiempo_postergacion

FROM
    mper p
    JOIN grados g ON p.per_grado = g.gra_codigo
    JOIN armas a ON p.per_arma = a.arm_codigo
    JOIN morg o ON p.per_plaza = o.org_plaza
    JOIN grados g2 ON g2.gra_codigo = o.org_grado
    JOIN mdep d ON d.dep_llave = o.org_dependencia
    JOIN min_unidades_organizacion muo ON muo.orgn_plaza = o.org_plaza
    JOIN min_puestos pu ON pu.puesto_id = muo.orgn_puesto
    JOIN tiempos t ON t.t_catalogo = p.per_catalogo
     LEFT JOIN evaluaciones ev ON p.per_catalogo = ev.e_catalogo
        AND ev.e_evaluacion = (
            SELECT MAX(e2.e_evaluacion)
            FROM evaluaciones e2
            WHERE e2.e_catalogo = p.per_catalogo
        )
        AND ev.e_numero = (
            SELECT MAX(e2.e_numero)
            FROM evaluaciones e2
            WHERE e2.e_catalogo = p.per_catalogo
              AND e2.e_evaluacion = ev.e_evaluacion
        )
     LEFT JOIN (
        SELECT
            counts.per_promocion,
            MIN(counts.t_ult_asc) AS ult_asc_mas_comun -- Usamos MIN para desempatar
        FROM
            (
                SELECT
                    p_in.per_promocion,
                    t_in.t_ult_asc,
                    COUNT(*) AS cantidad
                FROM mper p_in
                JOIN tiempos t_in ON p_in.per_catalogo = t_in.t_catalogo
                WHERE p_in.per_promocion != 0
                GROUP BY p_in.per_promocion, t_in.t_ult_asc
            ) counts
            JOIN (
                SELECT
                    max_c.per_promocion,
                    MAX(max_c.cantidad) AS max_cantidad
                FROM
                    (
                        SELECT
                            p_in2.per_promocion,
                            t_in2.t_ult_asc,
                            COUNT(*) AS cantidad
                        FROM mper p_in2
                        JOIN tiempos t_in2 ON p_in2.per_catalogo = t_in2.t_catalogo
                        WHERE p_in2.per_promocion != 0
                        GROUP BY p_in2.per_promocion, t_in2.t_ult_asc
                    ) max_c
                GROUP BY max_c.per_promocion
            ) max_vals ON counts.per_promocion = max_vals.per_promocion
            AND counts.cantidad = max_vals.max_cantidad
        GROUP BY counts.per_promocion
    ) pmf ON p.per_promocion = pmf.per_promocion
WHERE
    g.gra_clase IN (1, 2, 3, 4, 5, 6)
    and p.per_catalogo = 576173
ORDER BY clases ASC, promocion ASC;
















