package com.fy.tool.toolmaker.dao.impl;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

import com.fy.sqlparam.map.ISqlMapResult;
import com.fy.sqlparam.map.config.FieldMapMeta;
import com.fy.sqlparam.map.config.MapMetaConfig;
import com.fy.sqlparam.param.ISqlParameter;
import com.fy.tool.toolmaker.entity.ToolMakerEntity;
import com.fy.tool.toolmaker.dao.IToolMakerDao;
import com.fy.toolhelper.db.BaseDaoImpl;

/**
 * Dao的实现, 记得继承{@link BaseDaoImpl}
 * PS: 建议把默认的这个构造方法声明放最下面, 因为它的关注度远没有查询接口高, 这只是习惯, 不强制要求.
 */
public class ToolMakerDaoImpl extends BaseDaoImpl<ToolMakerEntity> implements IToolMakerDao {

	@Override
	public List<Map<String, Object>> getTables(Connection connection, String databaseName) throws Exception {
		String sql = "select table_name from information_schema.tables where table_schema = '"+databaseName+"';";
		String[] keys = {"table"};
		return this.getMapsBySql(connection,keys, sql,null);
	}

//	@Override
//	public List<Map<String, Object>> getTableFields(Connection connection, String tableName, String databaseName) throws Exception {
//		String sql = "select COLUMN_NAME from information_schema.COLUMNS " +
//				"where table_name = '"+tableName+"' and table_schema = '"+databaseName+"';";
//		String[] keys = {"field"};
//		return this.getMapsBySql(connection,keys, sql,null);
//	}

	public List<Map<String, Object>> getTableFields(Connection connection, String tableName, String databaseName) throws Exception {
		String sql = "SELECT COLUMN_NAME, DATA_TYPE FROM information_schema.COLUMNS " +
				"WHERE table_name = '" + tableName + "' AND table_schema = '" + databaseName + "';";
		String[] keys = {"columnName", "dataType"};
		List<Map<String, Object>> result=this.getMapsBySql(connection, keys, sql, null);
		//字节数组转化为字符串
		for (Map<String, Object> row : result) {
//			byte[] columnTypeBytes = (byte[]) row.get("dataType");
//			String columnType = new String(columnTypeBytes);
//			row.put("dataType", columnType);
			Object dataTypeObj = row.get("dataType");
			String columnType;
			if (dataTypeObj instanceof byte[]) {
				byte[] columnTypeBytes = (byte[]) dataTypeObj;
				columnType = new String(columnTypeBytes, StandardCharsets.UTF_8);
			} else if (dataTypeObj instanceof String) {
				columnType = (String) dataTypeObj;
			} else {
				// 处理其他类型的情况，或抛出异常
				System.out.println("读取出错");
				columnType = ""; // 或者设置一个默认值
			}

			row.put("dataType", columnType);
		}
		return result;
	}

	@Override
	public List<Map<String, Object>> showDataBases(Connection connection) throws Exception {
		String sql = "show databases";
		String[] keys = {"database"};
		return this.getMapsBySql(connection,keys, sql,null);
	}

	@Override
	public long getCountByParameter(Connection connection, ISqlParameter parameter) throws Exception {
		// 这是一个SQL模板, 
		String sql = "SELECT COUNT(1)" + PH_BASE_TABLES
				+ PH_DYNAMIC_JOIN_TABLES
				// 这里加当前接口需要额外关联的表.
				+ "WHERE"
				// 这里加当前接口需要的查询条件
				+ PH_CONDITIONS;
		// 调用这个formatSql格式化为真正的SQL
		ISqlMapResult mapResult = this.formatSql(sql, parameter);
		return this.getCountBySql(connection, mapResult.getSql(), 
				/*, 如果有额外占位参数, 值写在这里 , */mapResult.getArgObjs());
	}
	
	@Override
	public List<ToolMakerEntity> listByParameter(Connection connection, ISqlParameter parameter) throws Exception {
		String sql = "SELECT dr.*" + PH_BASE_TABLES
				+ PH_DYNAMIC_JOIN_TABLES
				+ "WHERE"
				+ PH_CONDITIONS
				+ PH_ORDER_BY + PH_LIMIT;
		ISqlMapResult mapResult = this.formatSql(sql, parameter);
		return this.listEntitiesBySql(connection, mapResult.getSql(), "te", mapResult.getArgObjs());
	}

	@Override
	public List<Map<String, Object>> listMapsByParameter(Connection connection, ISqlParameter parameter) throws Exception {
		// 查询时指定具体的字段, 查询结果按顺序输出
		String sql = "SELECT dr.id, dr.normal_column" + PH_BASE_TABLES
				+ PH_DYNAMIC_JOIN_TABLES
				+ "WHERE"
				+ PH_CONDITIONS
				+ PH_ORDER_BY;
		ISqlMapResult mapResult = this.formatSql(sql, parameter);
		return this.getMapsBySql(connection, new String[] {
			// 保证和语句中的查询顺序一致, 这是查询结果List<Map>中Map的Key
			"id", "normalColumn"
		}, mapResult.getSql(), mapResult.getArgObjs());
	}

	@Override
	public byte[] getAnyByParameter(Connection connection, ISqlParameter parameter) throws Exception {
		String sql = "SELECT te.byte_column " + PH_BASE_TABLES
				+ PH_DYNAMIC_JOIN_TABLES
				+ "WHERE"
				+ PH_CONDITIONS
				+ PH_ORDER_BY + PH_LIMIT;
		ISqlMapResult mapResult = this.formatSql(sql, parameter);
		// 主要靠这个IResultSetHandler回调进行ResultSet自定义处理
		// 强烈不建议自己使用Connection查询, 这样代码有冗余且容易没有释放内存.
		return this.executeSql(new IResultSetHandler<byte[]>() {
			@Override
			public byte[] handleResetSet(ResultSet rs) throws Exception {
				while(rs.next()) {
					return rs.getBytes(1);
				}
				return null;
			}
		}, connection, mapResult.getSql(), mapResult.getArgObjs());
	}
	
	/**
	 * <strong>**重要**: 这些注解配置为模板SQL和配合{@link ISqlParameter}动态查询提供基础信息.</strong>
	 * 这些配置有些地方不太好理解, 跟设计有关系, 请体谅.
	 */
	@MapMetaConfig(baseTables = "FROM register_tool rt",
			queryFields = {
					@FieldMapMeta(name = "id", value = "rt.id"),
					@FieldMapMeta(name = "toolName", value = "rt.tool_name"),
					@FieldMapMeta(name = "createTime", value = "rt.create_time"),
					@FieldMapMeta(name = "view_source", value = "rt.viewSource"),
					@FieldMapMeta(name = "isDeploy", value = "rt.is_deploy"),
					@FieldMapMeta(name = "fields", value = "rt.fields"),
					@FieldMapMeta(name = "toolDescription", value = "rt.tool_description"),
					@FieldMapMeta(name = "formulaFields", value = "rt.formula_fields"),
					@FieldMapMeta(name = "dataTableName", value = "rt.data_table_name"),
					@FieldMapMeta(name = "toolOtherName", value = "rt.tool_other_name"),
					@FieldMapMeta(name = "parentToolName", value = "rt.parent_tool_name"),
			}
	)
	public ToolMakerDaoImpl() throws Exception {
		super();
	}
}
