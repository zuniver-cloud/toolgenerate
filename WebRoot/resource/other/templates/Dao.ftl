package ${package_name}.dao;

import ${package_name}.entity.${entityName};
import com.fy.toolhelper.db.IBaseDao;
import com.fy.sqlparam.param.ISqlParameter;

import java.sql.Connection;
import java.util.List;

public interface I${entityName}Dao extends IBaseDao<${entityName}> {

    List<${entityName}> getAll${entityName}(Connection connection) throws Exception;

    List<${entityName}> getPage(Connection conn, ISqlParameter parameter) throws Exception;

    long getPageCount(Connection conn, ISqlParameter parameter) throws Exception;
}
