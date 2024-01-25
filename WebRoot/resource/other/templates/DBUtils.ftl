package ${package_name}.utils;

import ${package_name}.entity.DbColumn;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 根据表名获取全部字段
 * @description:
 * @author: linjintian
 **/
public class DBUtils {
    public static List<DbColumn> getColumnsByTableName(Connection connection, String name) throws SQLException {
        List<DbColumn> fields = new ArrayList<>();
        try {
            ResultSet resultSet = connection.getMetaData().getColumns(null, "%", name, "%");
            while (resultSet.next()) {
                DbColumn f = new DbColumn();

                f.setName(resultSet.getString("COLUMN_NAME"));
                f.setComment(resultSet.getString("REMARKS"));

                fields.add(f);
            }
        } catch (SQLException e) {
            throw e;
        }
        return fields;
    }

    public static String generateAddSQL(String tableName, Map<String, String> maps) {
        StringBuilder fieldsSQL = new StringBuilder();
        StringBuilder valuesSQL = new StringBuilder();

        Set<String> keys = maps.keySet();
        for (String k : keys) {
            fieldsSQL.append(String.format("`%s`,", k));
            valuesSQL.append(String.format("'%s',", maps.get(k)));
        }

        // 删掉最后逗号
        fieldsSQL.deleteCharAt(fieldsSQL.length() - 1);
        valuesSQL.deleteCharAt(valuesSQL.length() - 1);

        StringBuilder sql = new StringBuilder();
        sql.append(String.format("INSERT INTO `%s` (", tableName)).append(fieldsSQL.toString())
                .append(") VALUES (").append(valuesSQL.toString()).append(");");
        return sql.toString();
    }
}
