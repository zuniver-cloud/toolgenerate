package com.fy.tool.toolmaker.dao;

import java.sql.Connection;
import java.util.List;
import java.util.Map;

import com.fy.sqlparam.param.ISqlParameter;
import com.fy.tool.toolmaker.entity.ToolMakerEntity;
import com.fy.toolhelper.db.IBaseDao;

/**
 * 定义Dao接口
 * 基础{@link IBaseDao}使用该数据库封装处理
 * 默认IBaseDao已提供了简单的增删改接口实现, 所以不要重复写那些代码. 这里专注于查询接口和特殊需求即可.
 */
public interface IToolMakerDao extends IBaseDao<ToolMakerEntity> {
	/* 以下示例所有的ISqlParameter参数都是可选的, 取决于开发者对查询接口的灵活度的需求, 名字也没规定. */

	/**
	 * 使用搜索参数查询记录数量
	 * <br/><b>建议提供这种查询总数的接口为分页查询的记录总数提供支持</b>
	 * @param parameter
	 * @return
	 * @throws Exception
	 */
	long getCountByParameter(Connection connection, ISqlParameter parameter) throws Exception;
	
	/**
	 * 使用搜索参数查询实体列表
	 * <br/><b>{@link ISqlParameter}的作用主要是减少因为一些简单查询的参数不一样而需要创建多个接口的工作量</b>
	 * @param parameter 
	 * @return
	 * @throws Exception
	 */
	List<ToolMakerEntity> listByParameter(Connection connection, ISqlParameter parameter) throws Exception;
	
	/**
	 * 有些情况下, 需要混合几张表的某些字段作为返回结果, 而没有对应实体, 可以使用这种方式定义接口
	 * @param parameter
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> listMapsByParameter(Connection connection, ISqlParameter parameter) throws Exception;
	
	/**
	 * 特殊情况下, 需要自己解析查询返回值, 可以任意定义返回值类型 
	 * @param parameter
	 * @return
	 */
	byte[] getAnyByParameter(Connection connection, ISqlParameter parameter) throws Exception;

	List<Map<String, Object>> showDataBases(Connection connection) throws Exception;

	List<Map<String, Object>> getTables(Connection connection, String databaseName) throws Exception;

	List<Map<String, Object>> getTableFields(Connection connection, String tableName, String databaseName) throws Exception;
}
