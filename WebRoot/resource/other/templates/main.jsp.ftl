<%@ page import="java.util.*" contentType="text/html; charset=utf-8" %>
<!DOCTYPE HTML>
<html>
<head>
    <title>${tool_name}</title>
    <link rel="stylesheet" href="${r'${resourceUrl}'}css/element-ui-2.13.1.css">
    <link rel="stylesheet" href="${r'${resourceUrl}'}css/muse-ui.css">
    <link rel="stylesheet" type="text/css" href="${r'${resourceUrl}'}css/main.css">
    <meta name="viewport" content="initial-scale=1, maximum-scale=1">
    <link rel="shortcut icon" href="${r'${resourceUrl}'}images/favicon.ico">

</head>
<body>

<div id="app" v-cloak>
<#--    <div class="title">-->
<#--        <div style="display: flex; flex-direction: column; margin-right: auto;">-->
    <div class="title" style="background-color: #409EFF;height: 10%">
        <div style="display: flex; flex-direction: column; margin-right: auto;">
            <span id="title-content">${tool_name}</span>
            <span v-show="updateDescription" class="description" v-text="updateDescription"></span>
        </div>
<#--        改动-->
<#--        <#if n_view_tool>-->


<#--            <#if hasExport>-->
<#--                <button v-show="isMobile" id="title-add-btn" @click="downloadExcelData()"><i class="el-icon-download"></i></button>-->
<#--            </#if>-->

<#--            <#if hasImport>-->
<#--                <button v-show="isMobile" id="title-add-btn" @click="uploadDialog = true"><i class="el-icon-upload2"></i></button>-->
<#--            </#if>-->

<#--        </#if>-->
<#--        <button v-show="isMobile" id="title-search-btn" @click="mobileSearchVisible = true"><i class="el-icon-search"></i></button>-->
    </div>
<#--    <transition name="slide-fade" v-cloak>-->
<#--        <div id="search-div" v-show="mobileSearchVisible" v-cloak>-->
<#--            <input id="search-input" type="text" v-model="searchKey" @keyup.enter="search(1)" placeholder="输入内容按回车键搜索"/>-->
<#--            <button id="search-submit-btn" @click="search(1)">-->
<#--                <i class="el-icon-search"></i>-->
<#--            </button>-->
<#--            <button id="search-close-btn" @click="resetSearch()">-->
<#--                <i class="el-icon-close"></i>-->
<#--            </button>-->
<#--        </div>-->
<#--    </transition>-->


    <el-container  v-show="!isMobile" style="height:100vh;padding-top: 70px">
        <el-aside v-show="menuList.length > 1" width="230px">
            <el-menu
                    @select="handleSelect"
                    :default-active="menuList[0].table"
                    class="el-menu-vertical-demo">
                <el-menu-item :index="item.table" v-for="item in menuList">
                    <i class="el-icon-menu"></i>
                    <span slot="title">{{ item.label }}</span>
                </el-menu-item>
            </el-menu>
        </el-aside>

    <div id="content" :class="{'single-table': menuList.length == 1}">
<#--        头部操作信息-->
        <div id="header"  v-show="!isMobile">
            <#if n_view_tool>
            <div style="display: flex;flex-direction: column;width: 100%">
<#--                分类展示-->
                <#if classifyList?size != 0>
                 <#if classifyList[0].name!="">
                <div style="width: 100%">
                    <div style="margin: 5px 0;background: #FFFFFF;border: 1px solid #e6e7ec;">
                        <div style="background: #e6e7ec;height: 36px;display: flex;align-items: center;padding: 0 10px;">
                            分类展示
                        </div>
                        <div style="padding: 10px;display: flex;align-items: center;">
                            <template>
                                <#list classifyList as button>
                                    <div style="margin: 0px 15px">
                                        <#--                                        改动2-->
                                        <el-button @click="handleClassifyClick('${button.value}')"
                                        >
                                            ${button.name}
                                        </el-button>
                                    </div>
                                </#list>
                            </template>
                            <#if hasAdd>
                            <div style="flex: 1;text-align: right;padding-right: 10px;">
                                <el-button icon="el-icon-plus" type="success" style="margin-right: 10px" @click="handleAdd()">新增记录</el-button>
                            </div>
                            </#if>
                        </div>
                    </div>
                </div>
                </#if>
                </#if>
<#--                搜索框-->
                <#if searchList?size != 0>
                <#if searchList[0].name!="">
                    <div style="width: 100%">
                    <div style="margin: 5px 0;background: #FFFFFF;border: 1px solid #e6e7ec;">
                        <div style="background: #e6e7ec;height: 36px;display: flex;align-items: center;padding: 0 10px;">
                            筛选查询
                        </div>
                        <div style="padding: 10px;display: flex;align-items: center;">
                            <template>
                                <#list searchList as item>
                                    <div style="display: flex; flex: 1; margin: 0px 10px;">
                                        <span style="display: flex; margin-left: 7px; vertical-align: center; align-items: center;">${item.searchDes}</span>
<#--                                        改动2-->
                                        <el-input v-model="search${item.name}"></el-input>
                                    </div>
                                </#list>
                            </template>
                            <div style="flex: 1;text-align: right;padding-right: 10px;">
                                <el-button icon="el-icon-search" type="primary" style="margin-right: 10px" @click="searchByItem()">查询</el-button>
                            </div>
                        </div>
                    </div>
                </div>
                </#if>
                </#if>
<#--                表格操作-->
                <div style="margin: 5px 0px 0px 20px;background: #FFFFFF;">
                    <#if hasExport>
                        <el-button type="success" @click="downloadExcelModel">生成Excel空表</el-button>&nbsp;&nbsp;
                        <el-button type="primary" @click="downloadExcelData">生成Excel表格</el-button>&nbsp;&nbsp;
                    </#if>
                    <#if hasImport>
                        <el-upload
                                id="upload-el"
                                ref="upload"
                                :action="uploadUrl"
                                :on-change="handleChange"
                                :on-remove="handleRemove"
                                :on-success="handleUploadSuccess"
                                :file-list="fileList"
                                :limit="1"
                                :auto-upload="false"
                                style="display: inline">
                            <el-button slot="trigger" type="primary">从Excel表添加记录</el-button>
                            <el-button style="margin-left: 10px;" v-show="showUploadBtn" type="success" @click="submitUpload">开始导入</el-button>
                        </el-upload>
                    </#if>
                </div>
            </div>
            </#if>


<#--            <#if n_view_tool>-->
<#--                <#if hasAdd>-->
<#--                    <el-button id="add-btn" type="success" icon="el-icon-plus" @click="handleAdd()">添加记录</el-button>-->
<#--                </#if>-->


<#--    &lt;#&ndash;            <span style="float: left;margin-right: 10px;">导入数据：</span>&ndash;&gt;-->
<#--                <#if hasImport>-->
<#--                    <el-button type="primary" @click="downloadExcelModel">生成Excel空表</el-button>&nbsp;&nbsp;-->
<#--                </#if>-->
<#--                <#if hasExport>-->
<#--                    <el-button type="primary" @click="downloadExcelData">生成Excel表格</el-button>&nbsp;&nbsp;-->
<#--                </#if>-->
<#--            </#if>-->
<#--            <#if n_view_tool && hasImport>-->
<#--            <el-upload-->
<#--                    id="upload-el"-->
<#--                    ref="upload"-->
<#--                    :action="uploadUrl"-->
<#--                    :on-change="handleChange"-->
<#--                    :on-remove="handleRemove"-->
<#--                    :on-success="handleUploadSuccess"-->
<#--                    :file-list="fileList"-->
<#--                    :limit="1"-->
<#--                    :auto-upload="false">-->
<#--                <el-button slot="trigger" type="primary">从Excel表添加记录</el-button>-->
<#--                <el-button style="margin-left: 10px;" v-show="showUploadBtn" type="success" @click="submitUpload">开始导入</el-button>-->
<#--            </el-upload>-->
<#--            </#if>-->
<#--            <div id="pc-search-div" v-show="!openSuperSearch">-->
<#--                <el-input placeholder="输入内容按回车键全表搜索" @keyup.enter.native="search(1)" v-model="searchKey"></el-input>-->
<#--                <el-button style="margin-left: 10px;" type="success" icon="el-icon-search"  @click="search(1)">搜索</el-button>-->
<#--                <el-button  type="primary" v-show="showResetSearchBtn" icon="el-icon-refresh" @click="resetSearch()">重置</el-button>-->
<#--            </div>-->
<#--            <el-button style="margin-right: 10px" type="success" icon="el-icon-search"  @click="openSuperSearch=!openSuperSearch" >-->
<#--                {{ openSuperSearch==false?"高级搜索":"普通搜索"}}-->
<#--            </el-button>-->
<#--            <div id="pc-super-search-div" v-show="openSuperSearch">-->
<#--                <el-input placeholder="输入内容按回车键全表搜索" @keyup.enter.native="search(1,searchField)" v-model="searchKey"></el-input>-->
<#--                <el-select v-model="searchField" placeholder="请选择">-->
<#--                    <el-option-->
<#--                            v-for="(item,index) in superSearchField"-->
<#--                            :key="index"-->
<#--                            :label="item.label"-->
<#--                            :value="item.value"-->
<#--                    >-->
<#--                    </el-option>-->
<#--                </el-select>-->
<#--                <el-button style="margin-left: 10px;" type="success" icon="el-icon-search"  @click="search(1,searchField)">搜索</el-button>-->
<#--            </div>-->

        </div>

        <%--pc端显示表格--%>
        <el-main ref="elMain" v-show="!isMobile" id="table-el-main">

            <#list tables as t>
                <el-table v-if="selectTable == '${t.pinyinOfEntityName}'" :data="dataList" tooltip-effect="light" @row-click="clickRow" ref="table" border height="100%"  align="center" v-loading="loading" header-cell-class-name="header-cell">
                <el-table-column
                        type="index"
                        align="center"
                        label="序号"
                        width="50"
                        :index="(page-1)*pageSize+1">
                </el-table-column>
                <el-table-column type="expand" width="1">
                    <template slot-scope="props">
                        <el-form label-position="left" inline class="demo-table-expand">
                               <#if t.columns??>
                                   <#list t.columns as c>
                                       <#if (c.changedName != 'id')>
                                           <el-form-item label="${c.showName!}：">
                                               <span v-html="props.row.${c.changedName}"></span>
                                           </el-form-item>
<#--                                           <#if c.changedName?starts_with("column")>-->
<#--                                        <el-form-item label="${c.showName!}：">-->
<#--                                            <span v-html="props.row.${c.changedName}"></span>-->
<#--                                        </el-form-item>-->
<#--                                           <#else>-->
<#--                                       <el-form-item label="${c.formulaName!}：">-->
<#--                                           <span v-html="props.row.${c.changedName}"></span>-->
<#--                                       </el-form-item>-->
<#--                                           </#if>-->
                                       </#if>
                                   </#list>
                               </#if>
                        </el-form>
                    </template>
                </el-table-column>
                <#if t.columns??>
                    <#list t.columns as c>
                        <#if (c.changedName != 'id')>
                            <#if c.type?upper_case == 'BIT'>
                    <el-table-column prop="${c.changedName}" label="${c.showName!}" align="center">
<#--                                <#if c.changedName?starts_with("column")>-->
<#--                <el-table-column prop="${c.changedName}" label="${c.showName!}" align="center">-->
<#--                                <#else >-->
<#--                <el-table-column prop="${c.changedName}" label="${c.formulaName!}" align="center">-->
<#--                                </#if>-->
                    <template slot-scope="scope">{{scope.row.${c.changedName} ? '1': '0'}}</template>
                </el-table-column>
                            <#else>
                                <el-table-column :show-overflow-tooltip="!isMobile && !showResetSearchBtn" label="${c.showName!}" align="center">
<#--                                <#if c.changedName?starts_with("column")>-->
<#--                <el-table-column :show-overflow-tooltip="!isMobile && !showResetSearchBtn" label="${c.showName!}" align="center">-->
<#--                                <#else >-->
<#--                <el-table-column :show-overflow-tooltip="!isMobile && !showResetSearchBtn" label="${c.formulaName!}" align="center">-->
<#--                                </#if>-->
                    <template slot-scope="props">
                        <div v-if="showResetSearchBtn" v-html="getSubStringWhenTooLong(props.row.${c.changedName})">
                        </div>
                        {{ showResetSearchBtn ? '' : getSubStringWhenTooLong(props.row.${c.changedName}) }}
                    </template>
                </el-table-column>
                            </#if>
                        </#if>
                    </#list>
                </#if>
<#--                <#if n_view_tool && hasControl>-->
<#--                <el-table-column label="操作" align="center" width="160">-->
<#--                    <template slot-scope="scope">-->
<#--                        <el-button @click.stop size="mini" type="primary" @click="handleEdit(scope.$index, scope.row)">编辑</el-button>-->
<#--                        <el-button @click.stop size="mini" type="danger" @click="handleDelete(scope.$index, scope.row)">-->
<#--                            删除-->
<#--                        </el-button>-->
<#--                    </template>-->
<#--                </el-table-column>-->
<#--                </#if>-->
<#--                    改动-->
                    <#if n_view_tool>
                        <el-table-column label="操作" align="center" width="260px">
                            <template slot-scope="scope">
                                <#if hasToolControl>
                                    <el-button @click.stop size="mini" type="primary" plain @click="toolUseClick(scope.row)">
                                        ${toolControlDes!}
                                    </el-button>
                                </#if>
                                <#if hasViewControl>
                                    <el-button @click.stop size="mini" type="primary" plain @click="clickRow(scope.row)">
                                        查看
                                    </el-button>
                                </#if>
                                <#if hasUpdateControl>
                                    <el-button @click.stop size="mini" type="primary" plain @click="handleEdit(scope.$index, scope.row)">
                                        编辑
                                    </el-button>
                                </#if>
                                <#if hasDeleteControl>
                                    <el-button @click.stop size="mini" type="primary" plain @click="handleDelete(scope.$index, scope.row)">
                                        删除
                                    </el-button>
                                </#if>
                            </template>
                        </el-table-column>
                    </#if>
            </el-table>
            </#list>
            <div class="company-pager">
<#--                <span>${company}</span>-->
                <el-pagination
                        :small="isMobile"
                        id="pagination"
                        background
                        @size-change="handleSizeChange"
                        @current-change="handleCurrentChange"
                        :current-page="page"
                        :page-sizes="[5, 10, 15, 20, 30, 40]"
                        :page-size="pageSize"
                        :layout="paginationLayout"
                        :total="total">
                </el-pagination>
            </div>
        </el-main>
    </div>

    </el-container>
<#--    <%--移动端显示无限滚动列表--%>-->
<#--    <el-main id="mobile" v-show="isMobile" v-cloak>-->
<#--        <el-tabs v-model="selectTable" @tab-click="handleTab">-->
<#--            <el-tab-pane  v-for="item in menuList" :label="item.label" :name="item.table"></el-tab-pane>-->
<#--        </el-tabs>-->
<#--        <mu-load-more @refresh="refresh" :refreshing="refreshing"  :loading="loadingForLoadMore" @load="loadMore">-->

<#--            <#list tables as t>-->
<#--            <ul v-if="selectTable == '${t.pinyinOfEntityName}'" >-->
<#--                <li v-for="row in dataList" :key="row.id" v-longpress="{handler: longTap,param: row}" @click="viewDetail(row)">-->
<#--                    <#if t.columns??>-->
<#--                        <#list t.columns as c>-->
<#--                            <#if (c.changedName != 'id')>-->
<#--                                <#if c.changedName?starts_with("column")>-->
<#--                                    <div><span class="label">${c.comment!}:</span><span v-html="row.${c.changedName}"></span></div>-->
<#--                                <#else >-->
<#--                                    <div><span class="label">${c.formulaName!}:</span><span v-html="row.${c.changedName}"></span></div>-->
<#--                                </#if>-->
<#--                            </#if>-->
<#--                        </#list>-->
<#--                    </#if>-->
<#--                </li>-->
<#--            </ul>-->
<#--            </#list>-->
<#--            <div id="mobile-empty" v-if="!loadingForLoadMore && dataList.length === 0">-->
<#--                <i class="el-icon-warning" style="font-size: 3em;"></i>-->
<#--                <br>-->
<#--                无数据-->
<#--            </div>-->
<#--            <div id="data-end" v-else-if="!loadingForLoadMore && page >=  totalPage">-->
<#--                <p>总共有{{ total }} 条数据</p>-->
<#--                <p>- - - 到底了 - - -</p>-->
<#--            </div>-->
<#--        </mu-load-more>-->

<#--        <#if hasAdd>-->
<#--            <el-button id="mobile-add-btn" @click="handleAdd()" type="primary" icon="el-icon-plus" circle></el-button>-->
<#--         </#if>-->
<#--    </el-main>-->

    <#if n_view_tool>
    <el-dialog v-cloak :title="formTitle" :visible.sync="formVisible" :width="dialogWidth" top="4vh" :before-close="handleClose">

        <#list tables as t>
        <el-form v-if="selectTable == '${t.pinyinOfEntityName}'" :model="form" :label-position="labelPosition"  @submit.native.prevent="commitForm()" style="text-align: left">
            <#if t.columns??>
                <#list t.columns as c>
                    <#if (c.changedName != 'id')>
<#--                        <#if (c.changedName?starts_with("column"))>-->
                <el-form-item label="${c.showName}" :label-width="formLabelWidth">
                        <#if c.type?upper_case == 'BIT'>
                            <el-switch v-model="form.${c.changedName}"></el-switch>
                        <#elseif c.type?upper_case == 'INT' || c.type?upper_case == 'BIGINT' || c.type?upper_case == 'SMALLINT' || c.type?upper_case == 'TINYINT' || c.type?upper_case == 'NUMERIC' || c.type?upper_case == 'DECIMAL'>
                    <el-input v-model="form.${c.changedName}" autocomplete="off" autofocus type="number"></el-input>
                        <#elseif c.type?upper_case == 'TIMESTAMP' || c.type?upper_case == 'DATE'>
                    <el-date-picker
                            v-model="form.${c.changedName}" value-format="yyyy-MM-dd" placeholder="选择日期"
                            :picker-options="{
                                shortcuts: [{text: '今天',onClick(picker) {picker.$emit('pick', new Date());}}],
                                disabledDate(time) { return time.getTime() > Date.now(); }
                            }">
                    </el-date-picker>
                        <#elseif c.type?upper_case == 'TIME'>
                    <el-time-picker
                            v-model="form.${c.changedName}" value-format="HH:mm:ss" placeholder="选择时间">
                    </el-time-picker>
                        <#else>
                    <el-input type="textarea" rows="2" v-model="form.${c.changedName}" autocomplete="off" autofocus></el-input>
                        </#if>
                </el-form-item>
<#--                        </#if>-->
                    </#if>
                </#list>
            </#if>
        </el-form>
        </#list>
        <div slot="footer" class="dialog-footer">
            <el-button @click="formVisible = false; handleClose(function(){})">取 消</el-button>
            <el-button type="primary" @click="commitForm()">确 定</el-button>
        </div>
    </el-dialog>
    </#if>



<#--    <%--底部弹窗--%>-->
<#--    <#if hasControl>-->

<#--    <el-drawer-->
<#--            id="bottom-dialog"-->
<#--            :with-header="false"-->
<#--            :visible.sync="bottomSheet"-->
<#--            direction="btt">-->
<#--        <h3>操作</h3>-->
<#--        <div  id="bottom-dialog-body" @click="bottomSheet = false">-->
<#--            <div class="sheet-item" @click="handleEdit(0, selectItem)">-->
<#--                <div><i class="el-icon-edit" style="color: #0090bf;font-size: 1.1em;"></i>编辑</div>-->
<#--            </div>-->
<#--            <div class="sheet-item" @click="handleMobileDelete(selectItem.id)">-->
<#--                <div><i class="el-icon-delete" style="color: red;font-size: 1.1em;"></i>删除</div>-->
<#--            </div>-->
<#--        </div>-->
<#--    </el-drawer>-->

<#--    </#if>-->


    <%--移动端详情页--%>

<#--    <#list tables as t>-->
<#--    <el-dialog v-if="selectTable == '${t.pinyinOfEntityName}'" v-cloak title="详情" :visible.sync="mobileDetailDialog" :width="dialogWidth" top="4vh">-->
<#--          <#if t.columns??>-->
<#--              <#list t.columns as c>-->
<#--                  <#if (c.changedName != 'id')>-->
<#--                      <#if c.changedName?starts_with("column")>-->
<#--                      <div class="detail-item" >-->
<#--                          <p>${c.comment}</p>-->
<#--                          <div class="line"></div>-->
<#--                          <div v-html="selectItem.${c.changedName}"></div>-->
<#--                      </div>-->
<#--                      <#else >-->
<#--                      <div class="detail-item" >-->
<#--                          <p>${c.formulaName}</p>-->
<#--                          <div class="line"></div>-->
<#--                          <div v-html="selectItem.${c.changedName}"></div>-->
<#--                      </div>-->
<#--                      </#if>-->
<#--                  </#if>-->
<#--              </#list>-->
<#--          </#if>-->
<#--        <div slot="footer" class="dialog-footer">-->
<#--            <el-button type="primary" @click="mobileDetailDialog = false">关闭</el-button>-->
<#--        </div>-->
<#--    </el-dialog>-->
<#--    </#list>-->

<#--    <#if n_view_tool>-->
<#--    <%--移动设备上传窗口--%>-->
<#--    <el-dialog v-cloak title="导入数据" id="mobile-import-dialog" :visible.sync="uploadDialog" :width="dialogWidth" top="15vh" :before-close="handleClose">-->
<#--        <el-upload-->
<#--                ref="upload"-->
<#--                :action="uploadUrl"-->
<#--                :on-remove="handleRemove"-->
<#--                :on-success="handleUploadSuccess"-->
<#--                :on-change="handleChange"-->
<#--                :file-list="fileList"-->
<#--                :limit="1"-->
<#--                :auto-upload="false">-->
<#--            <el-button slot="trigger" type="primary">从Excel表添加记录</el-button>-->
<#--            <el-button style="margin-left: 10px;"  v-show="showUploadBtn" type="success" @click="submitUpload">开始导入</el-button>-->
<#--        </el-upload>-->
<#--        <div slot="footer" class="dialog-footer" id="mobile-dialog-footer">-->
<#--            <el-button type="primary" @click="downloadExcelModel">生成Excel空表</el-button>-->
<#--            <el-button type="primary" @click="downloadExcelData">生成Excel表格</el-button>-->
<#--            <el-button @click="resetFile">重置</el-button>-->
<#--        </div>-->
<#--    </el-dialog>-->
<#--    </#if>-->
</div>

<script type="text/javascript" src="${r'${resourceUrl}'}js/jquery-1.8.0.min.js"></script>
<script type="text/javascript" src="${r'${resourceUrl}'}js/vue.js"></script>
<script type="text/javascript" src="${r'${resourceUrl}'}js/element-ui-2.13.1.js"></script>
<script type="text/javascript" src="${r'${resourceUrl}'}js/axios.min.js"></script>
<script type="text/javascript" src="${r'${resourceUrl}'}js/muse-ui.js"></script>
<script type="text/javascript">
    var fyToolUrl = '${r'${actionUrl}'}';
    var fyForwardUrl = '${r'${forwardUrl}'}';
    var fyResource = '${r'${resourceUrl}'}';
    var fyCallToolUrl = '${r'${runToolUrl}'}';
    var objectID = '${r'${objectID}'}';
    var key;
    var bandID = '${r'${bandID}'}';


    var userId = '${r'${userID}'}'; // 当前用户账号
    var accessToken = '${r'${accessToken}'}'; // 当前用户的accessToken
    var rtParam = '${r'${toolParam}'}'; // 工具运行参数
    var clientType = '${r'${clientType}'}'; // 工具当前的运行平台
    var thisToolId = '${r'${toolID}'}'; // 工具的ID
    var coreUrl = '${r'${openInterfaceUrl}'}';
    var userAccount = '${r'${userAccount}'}';
</script>
<script type="text/javascript" src="${r'${resourceUrl}'}js/main.js"></script>
</body>
</html>