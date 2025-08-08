          
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
    pmf.ult_asc_mas_comun AS ult_asc_mas_comun_promo,(case when e_diagnost =1      then 'DEFICIT'
                 WHEN e_diagnost=2        THEN 'NORMAL'
                 WHEN e_diagnost=3        THEN 'SOBREPESO'
                 WHEN e_diagnost=4        THEN 'OBESIDAD' end)  as perfil_biofisico
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
    GROUP BY clase, promocion,catalogo,grado,arma,nombre,fecha_nombramiento,desc_empleo,
    empleo,dependencia,plaza,grado_rec_puesto,years_puesto,meses_puesto,
    dias_puesto,prox_ascenso,ultimo_ascenso_individual,tiempo_como_oficial,sexo,ult_asc_mas_comun_promo,clases,perfil_biofisico
ORDER BY clases asc , promocion asc;