package com.fy.tool.toolmaker.core;

import java.io.InputStream;
import java.sql.*;
import java.util.*;

public class ToolMakerUtil {

    public static Connection getConnection() throws Exception {
        InputStream resourceStream = ToolMakerUtil.class.getClassLoader().getResourceAsStream("config.properties");
        Properties properties = new Properties();
        properties.load(resourceStream);

        String JDBC_DRIVER = properties.getProperty("JDBC_DRIVER");
        String JDBC_URL = properties.getProperty("JDBC_URL");
        String JDBC_USERNAME = properties.getProperty("JDBC_USERNAME");
        String JDBC_PASSWORD = properties.getProperty("JDBC_PASSWORD");

        Class.forName(JDBC_DRIVER);
        return DriverManager.getConnection(JDBC_URL, JDBC_USERNAME, JDBC_PASSWORD);
    }

    public static Map<String, DbTable> getDbTables(Connection conn) throws SQLException {
        Map<String, DbTable> dbTables = new HashMap<>();

        DatabaseMetaData databaseMetaData = conn.getMetaData();
        ResultSet tableSet = databaseMetaData.getTables(null, "%", "%", new String[]{"TABLE"});
        while (tableSet.next()) {
            String tableName = tableSet.getString("TABLE_NAME");
            ResultSet columnSet = databaseMetaData.getColumns(null, "%", tableName, "%");

            List<DbColumn> dbColumns = new ArrayList<>();
            DbColumn column;
            while (columnSet.next()) {
                column = new DbColumn();
                column.setName(columnSet.getString("COLUMN_NAME"));
                column.setType(columnSet.getString("TYPE_NAME"));
                column.setChangedName(underLineToCamelCase(columnSet.getString("COLUMN_NAME")));
                column.setComment(columnSet.getString("REMARKS"));
                dbColumns.add(column);
            }
            DbTable table = new DbTable();
            table.setName(tableName);
            table.setColumns(dbColumns);
            dbTables.put(tableName, table);
        }

        return dbTables;
    }
    //修改
    public static String underLineToCamelCase(String input) {
        StringBuilder sb = new StringBuilder();
        boolean capitalizeNextChar = false;

        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);

            if (c == '_') {
                capitalizeNextChar = true;
            } else {
                if (capitalizeNextChar) {
                    sb.append(Character.toUpperCase(c));
                    capitalizeNextChar = false;
                } else {
                    sb.append(c);
                }
            }
        }

        return sb.toString();
    }

    public static String camelCaseToUnderLine(String input) {
        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);

            if (Character.isUpperCase(c)) {
                if (i > 0) {
                    sb.append('_');
                }
                sb.append(Character.toLowerCase(c));
            } else {
                sb.append(c);
            }
        }

        return sb.toString();
    }

    //旧方法：转换不成功
//    public static String underLineToCamelCase(String str) {
//        StringBuilder builder = new StringBuilder(str);
//        int count = builder.indexOf("_");
//        while (count != 0) {
//            int num = builder.indexOf("_", count);
//            count = num + 1;
//            if (num != -1) {
//                char ss = builder.charAt(count);
//                if ((int) ss >= 'a' && (int) ss <= 'A') {
//                    ss = (char) (ss - 32);
//                }
//                builder.replace(count, count + 1, ss + "");
//            }
//        }
//        return builder.toString().replaceAll("_", "");
//    }

}
