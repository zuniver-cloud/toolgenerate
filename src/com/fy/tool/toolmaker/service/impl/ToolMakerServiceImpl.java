package com.fy.tool.toolmaker.service.impl;

import java.sql.Connection;
import java.util.List;
import java.util.Map;

import com.fy.sqlparam.impl.SqlParameter;
import com.fy.sqlparam.impl.SqlParameter.Query;
import com.fy.sqlparam.param.ISqlParameter;
import com.fy.sqlparam.param.ISqlQuery;
import com.fy.tool.toolmaker.entity.ToolMakerEntity;
import com.fy.tool.toolmaker.service.IToolMakerService;
import com.fy.tool.toolmaker.action.ToolMaker;
import com.fy.tool.toolmaker.dao.IToolMakerDao;
import com.fy.toolhelper.db.IBaseDao;

public class ToolMakerServiceImpl implements IToolMakerService {

	public void doSomeBussiness() throws Exception {
		final Connection connection = ToolMaker.getDBConnection();
		ToolMaker.startTransaction();
		// 此调用获取数据库连接获取不到就会报错, 如果不希望报错请使用ActionTool.getNullableDBConnection()
		IToolMakerDao templateDao = ToolMaker.getBean(IToolMakerDao.class);
		templateDao.save(connection, new ToolMakerEntity());
		templateDao.update(connection, new ToolMakerEntity());
		templateDao.delete(connection, new ToolMakerEntity());
		// SQL动态查询参数实例
		ISqlParameter parameter = new SqlParameter();
		ISqlQuery query = parameter.query(Query.to("id").eq(111)
				.or(Query.to("id").eq(222)));
		if(true || false) {
			query.and(Query.to("id").eq(333)); /* 注意其保留了条件判断可断开的能力 */
		}
		// 等同于: 其它查询条件 AND (id = 444 OR id = 555), 注意有括号的
		query.and(Query.to("id").eq(444).or(Query.to("id").eq(555)));
		// 其它


//		parameter.markOrderBy("id", false); /* 可以多个, 按调用顺序排列 */
//		parameter.setPagination(page, count, offset)
//		parameter.deleteConditions();
//		parameter.deletePagination();
//		parameter.deleteQuery(query);
		List<ToolMakerEntity> entities = templateDao.listByParameter(connection, parameter);
		if(entities.isEmpty()) { /* 不会为null的 */
			return;
		}
		templateDao.extend(connection, entities, 
				new String[] {"extendAlias" /* 和DaoImpl构造器配置的@Extend的name一致*/},
				new IBaseDao<?>[] {ToolMaker.getBean(IToolMakerDao.class)} /* 能够查询出目标实体的Dao的实例 */);
		// ... 其它业务代码
		
		// 工具的业务异常
//		if(true) {
//			throw new ToolException("调试信息, 建议把相关变量的值输出", "用户查看的信息, 可选");
//		}
		
		/* 最后的事务提交, 如果上面的代码抛了异常, 会自动调用ToolMaker.rollBackTransactionIfUsed回滚事务
		 所以不用自己处理了 */
		ToolMaker.commitTransactionIfNeed();
	}


	@Override
	public List<Map<String, Object>> getTables(String databaseName) throws Exception {
		final Connection connection = ToolMaker.getDBConnection();
		IToolMakerDao toolMakerDao = ToolMaker.getBean(IToolMakerDao.class);
		return toolMakerDao.getTables(connection, databaseName);
	}

	@Override
	public List<Map<String, Object>> getTableFields(String tableName, String databaseName) throws Exception {
		final Connection connection = ToolMaker.getDBConnection();
		IToolMakerDao toolMakerDao = ToolMaker.getBean(IToolMakerDao.class);
		return toolMakerDao.getTableFields(connection, tableName, databaseName);
	}

	@Override
	public Integer addTool(ToolMakerEntity toolMakerEntity) throws Exception {
		final Connection connection = ToolMaker.getDBConnection();
		ToolMaker.startTransaction();
		IToolMakerDao toolMakerDao = ToolMaker.getBean(IToolMakerDao.class);
		toolMakerDao.save(connection, toolMakerEntity);
		ToolMaker.commitTransactionIfNeed();
		return 1;
	}

	@Override
	public List<Map<String, Object>> showDataBases() throws Exception {
		final Connection connection = ToolMaker.getDBConnection();
		IToolMakerDao toolMakerDao = ToolMaker.getBean(IToolMakerDao.class);
		return toolMakerDao.showDataBases(connection);
	}
}
