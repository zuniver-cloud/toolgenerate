package com.fy.tool.toolmaker.service;

import com.alibaba.fastjson.JSONObject;

import java.util.List;
import java.util.Map;

public interface CoreRemoteService {

	/*
	* 帮区相关
	* */
	Map<String, Object> getBandByBandObjIds(List<Long> bandObjIds) throws Exception;

	Map<String, Object> getBandByBandObjId(String ObjId) throws Exception;

	JSONObject getRolesInBand(Long bandId) throws Exception;

	JSONObject getUsersInBand(Long bandId) throws Exception;

	JSONObject getChatroomsInBand(Long bandId) throws Exception;

	JSONObject getDocumentsInBand(Long bandId) throws Exception;

	JSONObject getToolsInBand(Long bandId) throws Exception;

    JSONObject getVariablesInBand(Long bandId) throws Exception;

	JSONObject getBandByBandId(String bandId) throws Exception;


	/*
	* 机构相关
	* */
	JSONObject getOrganizationInfo(Long organizationId) throws Exception;

	JSONObject getDepartmentByOrganizationId(Long organizationId) throws Exception;

	JSONObject getPositionByOrganizationId(Long organizationId) throws Exception;

	JSONObject getMembersByOrganizationId(Long organizationId) throws Exception;

	// 获取用户所在机构的所在所有帮区
	JSONObject getBandsByOrganizationId(Long organizationId) throws Exception;
	// 获取帮区路径
	JSONObject getBandsPath(String bandId) throws Exception;

	/**
	 *部门相关
	 **/
	JSONObject getUsersInDepartment(Long departmentId) throws Exception;

	JSONObject getPositionsInDepartment(Long departmentId) throws Exception;

	/**
	 * 帮语相关
	 */
	JSONObject getUserByUserName(String userName) throws Exception;
	JSONObject getBandByBandName(String bandName) throws Exception;
	JSONObject getChatroomByChatroomName(String chatroomName, String bandId) throws Exception;
	JSONObject getToolByToolName(String toolName, String bandId) throws Exception;

	JSONObject getUserByUserId(Long userId) throws Exception;

	/**
	 * 根据角色名称获取帮区角色信息
	 * @param
	 * @return
	 * @throws Exception
	 */
	JSONObject getBandRolesByRoleName(String bandId, String roleName) throws Exception;

}
