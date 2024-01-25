package ${package_name}.dao.impl;

import ${package_name}.entity.${entityName};
import ${package_name}.dao.I${entityName}Dao;

import com.fy.sqlparam.map.ISqlMapResult;
import com.fy.sqlparam.param.ISqlParameter;

import com.fy.sqlparam.map.config.FieldMapMeta;
import com.fy.sqlparam.map.config.MapMetaConfig;
import com.fy.toolhelper.db.BaseDaoImpl;

import java.sql.Connection;
import java.util.List;

public class ${entityName}DaoImpl extends BaseDaoImpl<${entityName}> implements I${entityName}Dao {

    @Override
    public List<${entityName}> getAll${entityName}(Connection connection) throws Exception {
        return listEntitiesBySql(connection, "SELECT alias.* FROM ${table_name} alias", "alias");
    }

  @Override
    public List<${entityName}> getPage(Connection conn, ISqlParameter parameter) throws Exception {
    String sql = "SELECT alias.* FROM ${table_name} alias "

    + "WHERE"
    + PH_CONDITIONS
    + PH_ORDER_BY + PH_LIMIT;
    ISqlMapResult mapResult = this.formatSql(sql, parameter);
    return this.listEntitiesBySql(conn, mapResult.getSql(), "alias", mapResult.getArgObjs());
    }

    @Override
    public long getPageCount(Connection conn, ISqlParameter parameter) throws Exception {
    String sql = "SELECT COUNT(1)  FROM ${table_name} alias "
    + "WHERE"
    + PH_CONDITIONS;
    ISqlMapResult mapResult = this.formatSql(sql, parameter);
    return this.getCountBySql(conn, mapResult.getSql(), mapResult.getArgObjs());
    }


 @MapMetaConfig(baseTables = "FROM ${table_name} alias", queryFields = {
        <#if columns??>
            <#list columns as c>
            @FieldMapMeta(name = "${c.changedName?uncap_first}", value = "alias.${c.name}"),
            </#list>
        </#if>
            })
    public ${entityName}DaoImpl() throws Exception {
        super();
    }
}