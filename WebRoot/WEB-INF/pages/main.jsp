<%@ page import="java.util.*" contentType="text/html; charset=utf-8" %>
<!DOCTYPE HTML>
<html>
<head>
    <title>工具生成器</title>
    <link rel="stylesheet" href="${resourceUrl}css/element-ui.css">
    <link rel="stylesheet" type="text/css" href="${resourceUrl}css/main.css">
    <meta name="viewport" content="initial-scale=1, maximum-scale=1">
    <link rel="shortcut icon" href="${resourceUrl}images/favicon.ico">

</head>
<body>

<div id="app">
    <div class="title">
        <span>工具生成器</span>
    </div>
<%--    <div id="customizedFields" v-if="step == 4">--%>
<%--        <el-card class="box-card" id="my-box-card">--%>
<%--            <div slot="header" class="clearfix" @focus="drag">--%>
<%--                <span>已选中的字段</span>--%>
<%--            </div>--%>
<%--            <el-table--%>
<%--                    :data="form.fields"--%>
<%--                    style="width: 100%">--%>
<%--&lt;%&ndash;                <el-table-column&ndash;%&gt;--%>
<%--&lt;%&ndash;                        type="index"&ndash;%&gt;--%>
<%--&lt;%&ndash;                        label="列名"&ndash;%&gt;--%>
<%--&lt;%&ndash;                        :index="indexMethod"&ndash;%&gt;--%>
<%--&lt;%&ndash;                        width="50">&ndash;%&gt;--%>
<%--&lt;%&ndash;                </el-table-column>&ndash;%&gt;--%>
<%--                <el-table-column--%>
<%--                        prop="name"--%>
<%--                        label="字段名"--%>
<%--                        width="180">--%>
<%--                </el-table-column>--%>
<%--            </el-table>--%>
<%--        </el-card>--%>
<%--    </div>--%>
    <div id="main">
        <div id="contents">
            <el-steps id="mobile-step" :active="step">
                <el-step title="上传" icon="el-icon-upload"></el-step>
                <el-step title="数据库" icon="el-icon-folder"></el-step>
                <el-step title="修改" icon="el-icon-edit"></el-step>
<%--                <el-step title="公式" icon="el-icon-edit"></el-step>--%>
                <el-step title="功能" icon="el-icon-edit"></el-step>
                <el-step title="补充" icon="el-icon-edit"></el-step>
                <el-step title="完成" icon="el-icon-check"></el-step>
            </el-steps>
            <el-steps id="pc-step" :active="step" simple>
                <el-step title="上传文件建表" icon="el-icon-upload"></el-step>
                <el-step title="从数据库选表" icon="el-icon-folder"></el-step>
                <el-step title="字段修改" icon="el-icon-edit"></el-step>
<%--                <el-step title="公式" icon="el-icon-edit"></el-step>--%>
                <el-step title="功能定制" icon="el-icon-edit"></el-step>
                <el-step title="工具描述" icon="el-icon-edit"></el-step>
                <el-step title="完成" icon="el-icon-check"></el-step>
            </el-steps>
            <div id="page">
               <transition :name="fade">
                   <div id="upload" v-if="step == 1" key="upload">
                       <el-upload
                               class="upload-demo"
                               drag
                               action="${actionUrl}&action=upload"
                               :file-list="fileList"
                               :on-success="onUpload">
                           <i class="el-icon-upload"></i>
                           <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
                           <div class="el-upload__tip" slot="tip">请上传xls或xlsx格式的表格文件</div>
                           <div class="el-upload__tip" slot="tip"><i style="color: gray;">若不上传文件可直接跳过</i></div>
                       </el-upload>
                   </div>
                   <div id="database" v-else-if="step == 2" key="database">
                       <%--
                        options: [{value:'',label:'',children:[同options]}]
                       --%>
<%--                       <el-form :model="databaseInfo" class="demo-form-inline" v-if="hasDataBaseInfo == false">--%>
<%--                           <el-form-item label="账号">--%>
<%--                               <el-input v-model="databaseInfo.account" placeholder="请输入账号"></el-input>--%>
<%--                           </el-form-item>--%>
<%--                           <el-form-item label="密码">--%>
<%--                               <el-input v-model="databaseInfo.password" placeholder="请输入密码" show-password></el-input>--%>
<%--                           </el-form-item>--%>
<%--                           <el-form-item>--%>
<%--                               <el-button type="primary" @click="connectDatabase">连接</el-button>--%>
<%--                           </el-form-item>--%>
<%--                       </el-form>--%>
                   <div class="block" v-if="hasDataBaseInfo">
                       <span class="demonstration">数据库</span>
                       <el-cascader-panel
                               ref="cascader"
                          v-model="fieldsFromDatabase"
                          :options="options"
                          :show-all-levels="false"
                          :props="props"
                          @expand-change="handleExpandChange"
                          @change="handleChange"
                       >
                           <template slot-scope="{ node, data }">
                               <div style="text-align: left;">
                                   <span v-if="node.level === 1"  >库：{{ node.label }}</span>
                                   <span v-if="node.level === 2" >表：{{ node.label }}</span>
                                   <span v-if="node.level === 3" >列：{{ node.label }}</span>
                               </div>
                           </template>
                       </el-cascader-panel>
                   </div>
                   </div>
                   <div id="edit-field" v-else-if="step == 3" key="edit1">
                       <el-tabs v-model="selectTable" type="card" editable @edit="handleTabsEdit">
                           <el-tab-pane
                                   :key="index1"
                                   v-for="(item, index1) in tables"
                                   :name="index1 + ''" >
                               <span slot="label"><i class="el-icon-edit" @click="editTableName(index1)"></i> {{ item.tableName }}</span>
                               <el-form :model="item" :ref="'form' + index1" class="fields-form" >
                                   <el-form-item
                                           v-for="(field, index) in item.fields"
                                           :key="index"
                                           >
                                       <%--                               <el-checkbox class="search-checkbox" label="搜索字段" v-model="form.fields[index].search"></el-checkbox>--%>
                                       &nbsp;

                                       <el-select v-model="item.fields[index].type" :disabled="isFromDatabase" placeholder="字段类型">
                                           <el-option label="varchar" value="varchar"></el-option>
                                           <el-option label="text" value="text"></el-option>
                                           <el-option label="int" value="int"></el-option>
                                           <el-option label="bigint" value="bigint"></el-option>
                                           <el-option label="time" value="time"></el-option>
                                           <el-option label="date" value="date"></el-option>
                                       </el-select>
                                           &nbsp;
                                           &nbsp;
                                       <el-input :ref="'field-' + index1 + '-' + index" v-model="item.fields[index].name" :disabled="isFromDatabase" placeholder="字段名称(数据库中)"></el-input>
                                           &nbsp;
                                       <el-input :ref="'field-' + index1 + '-' + index" v-model="item.fields[index].showName" placeholder="字段名称（用于页面展示）"></el-input>
                                           &nbsp;
                                       <el-button v-if="!isFromDatabase" type="danger" size="small" title="删除" @click.prevent="removeHeader(index)" icon="el-icon-delete" circle></el-button>
                                   </el-form-item>
                               </el-form>
                           </el-tab-pane>
                       </el-tabs>

                       <div>
                           <el-button size="small" v-if="!isFromDatabase" type="primary" @click="addHeader" >新增字段</el-button>
                       </div>
                   </div>
<%--                   <div id="edit-formula" v-else-if="step == 4" key="edit2">--%>
<%--                       <div>--%>
<%--                       <h3>由前面的字段组合而成的新字段</h3>--%>
<%--                       <h4>第一列为a1,第n列为an,例如：a1/a2</h4>--%>
<%--                       <el-form ref="formulaForm" :model="formulaForm">--%>
<%--                           <el-form-item v-for="(item,index) in formulaForm.fields" :key="index">--%>
<%--                               <el-row type="flex" justify="center">--%>
<%--                                   <el-col :span="5">--%>
<%--                                       <el-input v-model="item.name" placeholder="名称"></el-input>--%>
<%--                                   </el-col>--%>
<%--                                   <el-col :xs="10" :sm="15" :offset="1">--%>
<%--                                       <el-input v-model="item.formula" @change="checkFormula(item.formula)" placeholder="公式"></el-input>--%>
<%--                                   </el-col>--%>
<%--                                   <el-col :span="2" :offset="1">--%>
<%--                                       <el-button type="danger" size="small" title="删除" @click.prevent="removeFormula(index)" icon="el-icon-delete" circle></el-button>--%>
<%--                                   </el-col>--%>
<%--                               </el-row>--%>
<%--                           </el-form-item>--%>
<%--                       </el-form>--%>
<%--                       <div>--%>
<%--                           <el-button size="small" type="primary" @click="addFormula">新增字段</el-button>--%>
<%--                           <el-button size="small" @click="removeAllFormula">删除表格</el-button>--%>
<%--                       </div>--%>
<%--                       </div>--%>
<%--                   </div>--%>
                   <div id="edit-function" v-else-if="step == 4" key="edit3">
                       <el-tabs tab-position="left" style="width:auto;height: auto; overflow:auto;">
                           <el-tab-pane label="基础功能">
                               <h2>请选择需要定制的基础功能：</h2>
                                <div style="margin:8px 40px;text-align: left">
                               <el-checkbox :disabled="isFromDatabase" v-model="toolForm.add">添加记录功能</el-checkbox>
                               <el-checkbox :disabled="isFromDatabase" v-model="toolForm.deleteControl">删除记录功能</el-checkbox>
                                 </div>
                               <div style="margin:8px 40px;text-align: left">
                               <el-checkbox :disabled="isFromDatabase" v-model="toolForm.updateControl">修改记录功能</el-checkbox>
                               <el-checkbox v-model="toolForm.viewControl">详情查看功能</el-checkbox>
                               </div>
                               <div style="margin:8px 40px;text-align: left">
                                   <el-checkbox v-model="toolUseControl">工具调用功能</el-checkbox>
                               </div>
                               <div style="margin:10px;display: flex;" v-if="toolUseControl">
                                   <el-select v-model="selectedToolId" placeholder="调用工具">
                                       <el-option
                                               v-for="item in tools"
                                               :key="item.value"
                                               :label="item.label"
                                               :value="item.value">
                                       </el-option>
                                   </el-select>
                                   <el-input style="margin-left: 10px;margin-right: 20px" v-model="toolControlButton" placeholder="该功能按钮的名称"></el-input>
                               </div>
                           </el-tab-pane>
                           <el-tab-pane label="搜索功能">
                               <h4 style="margin:10px 0px">请选择搜索字段，并为该搜索框添加提示文字：</h4>
                               <h4 style="margin:10px 0px">示例：选择 username 字段，搜索框名字为：员工姓名</h4>
<%--                               <el-alert--%>
<%--                                       title="请选择搜索字段，并为该搜索框添加提示文字"--%>
<%--                                       type="info"--%>
<%--                                       description="示例：选择 username 字段，搜索框名字为：员工姓名">--%>
<%--                               </el-alert>--%>
                               <div style="height: 120px;overflow-y:auto;overflow-x: hidden ">
                                   <el-form ref="searchForm" :model="searchForm">
                                       <el-form-item v-for="(item,index) in searchForm.fields" :key="index">
                                           <el-row>
                                               <el-col :span="6">
                                                   <el-select v-model="item.name" placeholder="字段名">
                                                       <el-option
                                                               v-for="field in tables[0].fields"
                                                               :key="field.name"
                                                               :label="field.name"
                                                               :value="field.name"
                                                       ></el-option>
                                                   </el-select>
                                               </el-col>
                                               <el-col :xs="7" :sm="14" :offset="1">
                                                   <el-input v-model="item.searchDes"  placeholder="搜索框名字"></el-input>
                                               </el-col>
                                               <el-col :span="2" :offset="1">
                                                   <el-button type="danger" size="small" title="删除" @click.prevent="removeSearch(index)" icon="el-icon-delete" circle></el-button>
                                               </el-col>
                                           </el-row>
                                       </el-form-item>
                                   </el-form>
                               </div>
                               <div>
                               <el-button size="small" type="primary" @click="addSearchForm">新增搜索框</el-button>
                               </div>
                           </el-tab-pane>
                           <el-tab-pane label="分类功能">
                               <h4 style="text-align: center;margin:10px 0px">请选择分类字段，并为每种分类命名：</h4>
                               <h5 style="text-align: center;margin:10px 0px">示例：选择 user_type 字段，可能的取值为：1 2，对应的分类名称为：1.普通用户 2.高级用户</h5>
                               <el-form ref="classifyForm" :model="classifyForm" style="overflow: auto ;height: 180px">
                               <h5 style="margin:10px 0px">第一步：选择字段</h5>
                                   <el-form-item>
                                        <el-select v-model="classifyForm.classifyKey" placeholder="字段名">
                                            <el-option
                                                    v-for="field in tables[0].fields"
                                                    :key="field.name"
                                                    :label="field.name"
                                                    :value="field.name"
                                            ></el-option>
                                        </el-select>
                                   </el-form-item>
                               <h5 style="margin:10px 0px">第二步：分类取值及命名</h5>
                                       <el-form-item v-for="(item,index) in classifyForm.classifyValue" :key="index">
                                           <el-row>
                                               <el-col :span="8" :offset="1">
                                                   <el-input v-model="item.value" placeholder="分类取值"></el-input>
                                               </el-col>
                                               <el-col :span="8" :offset="1">
                                                   <el-input v-model="item.name" placeholder="分类名称"></el-input>
                                               </el-col>
                                               <el-col :span="2" :offset="1">
                                                   <el-button type="danger" size="small" title="删除" @click.prevent="removeClassify(index)" icon="el-icon-delete" circle></el-button>
                                               </el-col>
                                           </el-row>
                                       </el-form-item>
                                   </el-form>
                               <div>
                                   <el-button size="small" type="primary" @click=" addClassifyForm">新增</el-button>
                               </div>
                           </el-tab-pane>
                           <el-tab-pane label="Excel功能">
                               <h2>请选择需要定制的表格操作：</h2>
                               <div style="margin:10px">
                                   <el-checkbox :disabled="isFromDatabase" v-model="toolForm.importData">Excel表格导入功能</el-checkbox>
                               </div>
                               <div style="margin:10px">
                                   <el-checkbox v-model="toolForm.exportData">Excel表格导出功能</el-checkbox>
                               </div>
                           </el-tab-pane>

<%--                           <h2>第一步：选择字段</h2>--%>
<%--                           <el-select v-model="selectedFields" multiple clearable>--%>
<%--                               <el-option--%>
<%--                                       v-for="field in form.fields"--%>
<%--                                       :key="field.name"--%>
<%--                                       :label="field.name"--%>
<%--                                       :value="field.name"--%>
<%--                               ></el-option>--%>
<%--                           </el-select>--%>
<%--                           <h2>第二步：输入字段值</h2>--%>
<%--&lt;%&ndash;                           <el-form :model="fieldValues">&ndash;%&gt;--%>
<%--&lt;%&ndash;                               <el-form-item v-for="field in selectedFields" :label="field.label" :key="field.value">&ndash;%&gt;--%>
<%--&lt;%&ndash;                                   <el-input v-model="fieldValues[field.value]"></el-input>&ndash;%&gt;--%>
<%--&lt;%&ndash;                               </el-form-item>&ndash;%&gt;--%>
<%--&lt;%&ndash;                           </el-form>&ndash;%&gt;--%>
<%--                       </el-tabs>--%>
<%--                       <div style="margin-top: 10px">--%>
<%--                           <el-button type="primary" @click="handleSubmit">提交</el-button>--%>
<%--                           <el-button @click="handleReset">重置</el-button>--%>
<%--                       </div>--%>
                   </div>
                   <div id="edit-info" v-else-if="step == 5" key="edit4">
                       <el-form :model="toolForm" ref="toolForm" class="fields-form" label-width="90px">
                           <el-form-item label="工具名称" :rules="{required: true, message: '工具名称不能为空', trigger: 'blur'}">
                               <el-input clearable v-model="toolForm.name" placeholder="输入工具名称"></el-input>
                           </el-form-item>
                           <el-form-item label="工具描述" :rules="[{ min: 10, max: 100, message: '长度在 10 到 100 个字符', trigger: 'blur' }]">
                               <el-input type="textarea"  clearable v-model="toolForm.description" placeholder="输入工具描述"></el-input>
                           </el-form-item>
                           <el-form-item label="创建者" :rules="[{ max: 100, message: '长度在100个字符以内', trigger: 'blur' }]">
                               <el-input type="textarea"  clearable v-model="toolForm.company" placeholder="创建者"></el-input>
                           </el-form-item>
<%--                           <p style=" text-align: left; font-size: 14px; color: #606266; line-height: 40px; ">功能定制:</p>--%>
<%--                           <el-checkbox v-model="toolForm.add">添加记录</el-checkbox>--%>
<%--                           <el-checkbox v-model="toolForm.importData">导入功能</el-checkbox>--%>
<%--                           <el-checkbox v-model="toolForm.exportData">导出功能</el-checkbox>--%>
<%--                           <el-checkbox v-model="toolForm.control">操作功能</el-checkbox>--%>
                       </el-form>
                   </div>
                   <div id="download" v-else="step == 6" key="down">
                       <el-form v-show="success" class="fields-form">
                           <i id="success-icon" class="el-icon-success"></i>
                           <p id="success-text">生成成功!</p>

                           <el-form-item id="down-btns">
<%--                               <el-button size="small" type="success"  plain @click="download">下载工具</el-button>--%>
                               <el-button size="small" type="success" plain @click="downloadSource">下载源码</el-button>
                               <el-button size="small" type="success" plain @click="downloadSQL">下载数据库脚本</el-button>
<%--                               <el-button size="small" type="success" plain @click="dialogVisible = true">预览模板</el-button>--%>
                           </el-form-item>
                       </el-form>
                       <el-dialog
                               title="预览"
                               :visible.sync="dialogVisible"
                               width="30%"
                               :before-close="handleClose">
                           <div>
                               <p>生成的工具模板</p>
                               <el-image
                                       style="width: 100px; height: 100px"
                                       src="${window.g_resourceUrl}resource/images/toolModel.png"
                                       :preview-src-list="['${window.g_resourceUrl}resource/images/toolModel.png']">
                               </el-image>
                           </div>
<%--                           <div>--%>
<%--                               <p>移动端的生成的工具模板</p>--%>
<%--                               <el-image--%>
<%--                                       style="width: 100px; height: 100px"--%>
<%--                                       src="${window.g_resourceUrl}resource/images/toolmakerModel-Mobile.png"--%>
<%--                                       :preview-src-list="['${window.g_resourceUrl}resource/images/toolmakerModel-Mobile.png']">--%>
<%--                               </el-image>--%>
<%--                           </div>--%>
                           <span slot="footer" class="dialog-footer">
                            <el-button @click="dialogVisible = false">取 消</el-button>
                            <el-button type="primary" @click="dialogVisible = false">确 定</el-button>
                          </span>
                       </el-dialog>
                   </div>
               </transition>
           </div>
            <div id="step-btn-div" >
                <transition name="btn-left">
                    <el-button v-if="step == 1" @click="editExcelHelp">
                        说明
                    </el-button>
                    <el-button v-else @click="--step;fade='left'">
                        <i class="el-icon-arrow-left"></i>&nbsp;上一步
                    </el-button>
                </transition>
                <transition name="btn-right" mode="out-in">
                    <el-button v-if="step < 5" type="primary" @click="checkForm" key="next">
                            {{ step == 1 ? '跳过' : '下一步' }}&nbsp;<i class="el-icon-arrow-right"></i>
                    </el-button>
                    <el-button v-if="step == 5" :disabled="buildBtnDisabled" type="primary" @click="makeTool" key="build">
                        生成工具&nbsp;<i class="el-icon-arrow-right"></i>
                    </el-button>
                    <el-button v-if="step == 6" @click="reload">
                        <i class="el-icon-refresh"></i>&nbsp;重置
                    </el-button>
                </transition>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript" src="${resourceUrl}js/jquery-1.8.0.min.js"></script>
<script type="text/javascript" src="${resourceUrl}js/vue.js"></script>
<script type="text/javascript" src="${resourceUrl}js/element-ui.js"></script>
<script type="text/javascript">

    window.g_runToolUrl = '${actionUrl}'; // 数据接口
    window.g_callToolUrl = '${runToolUrl}'; // 工具调用
    window.g_forwardUrl = '${forwardUrl}'; // 跳转接口fg_runToolUrl
    window.g_resourceUrl = '${resourceUrl}'; // 静态资源
    window.g_userId = '${userID}'; // 当前用户账号
    window.g_accessToken = '${accessToken}'; // 当前用户的accessToken
    window.g_bandId = '${bandID}'; // 当前运行的帮区ID
    window.g_rtParam = '${toolParam}'; // 工具运行参数
    window.g_clientType = '${clientType}'; // 工具当前的运行平台
    window.g_thisToolId = '${toolID}'; // 工具的ID
</script>
<script type="text/javascript" src="${resourceUrl}js/main.js"></script>
</body>
</html>