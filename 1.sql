------------------------------------------
--公开授信数据移植
------------------------------------------
DELETE FROM CCI_PUBLIC_CREDIT_INFO T
 WHERE T.RSV_02 = 'MIGRATION20160929048';
DELETE FROM CCI_REPORT_SYSTEM_CTL T
 WHERE T.RSV_02 = 'MIGRATION20160929048';
COMMIT;
--插入公开授信待补录表数据
INSERT INTO CCI_PUBLIC_CREDIT_INFO
  (SYS_CTL_ID,
   CREDIT_AGREEMENT_NO,
   BUSI_DATE,
   BORROWER_NAME,
   LOAN_CARD_NO,
   CURRENCY,
   LOAN_CREDIT,
   START_DATE,
   EXPIRY_DATE,
   LOAN_CREDIT_START_DATE,
   LOAN_CREDIT_CANCEL_REASON,
   CUSTOMER_CODE,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0480000' || ORGCODE ||
         LPAD(ID, 6, '0'), --上报报文系统控制号
         PROTO_NO,
         REPLACE(YWDATE, '-'),
         NAME,
         CARD_NO,
         MONEY_KIND,
         SXJY,
         REPLACE(START_DATE, '-'),
         REPLACE(END_DATE, '-'),
         REPLACE(LOGOUT_DATE, '-'),
         LOGOUT_REASON,
         '', --客户号
         '', --备用字段1
         'MIGRATION20160929048', --移植数据标志
         '', --备用字段3
         '', --备用字段4
         '', --备用字段5
         '' --备用字段6
    FROM MBT_OS_OPENAWARDTRUSTS T
    WHERE END_DATE > '2017-05-12';

--插入公开授信对应控制表数据
INSERT INTO CCI_REPORT_SYSTEM_CTL
  (SYS_CTL_ID,
   FILE_SEND_DATE,
   REPORT_BATCH_NO,
   MSG_RECORD_TRACKING_NO,
   MSG_RECORD_OPERATE_TYPE,
   MSG_RECORD_ROW,
   REPORT_FLAG,
   FEEDBACK_FLAG,
   DEPT_ID,
   OPERATING_STATE,
   REPORT_FILE_TYPE,
   MSG_RECORD_TYPE,
   BRANCH_ID,
   BRANCH_NO,
   RELATION_SYS_CTL_ID,
   ORG_BASIC_FEEDBACK_FLAG,
   OPERATE_TIME,
   OPERATER,
   CHECK_TIME,
   CHECK_OPERATOR,
   CHECK_ADD_MSG,
   LAST_UPDATE_TIME,
   LAST_UPDATER,
   LOGIC_DELETE_FLAG,
   DTL_NUM_A,
   DTL_NUM_B,
   DTL_NUM_C,
   DTL_NUM_D,
   RECORD_STATUS_FLAG,
   MESSAGE_TYPE,
   RELATION_FEEDBACK_ID,
   START_INDEX,
   END_INDEX,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06,
   CTL_BUSI_DATE)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0480000' || B.ORGCODE ||
         LPAD(ID, 6, '0'), --上报报文系统控制号
         REPLACE(B.RPTDATE, '-'), --上报日期
         '', --上报批次号
         B.TRACENO, --信息记录跟踪编号
         '1', --信息记录操作类型 1-正常 4-删除
         '', --记录行号(在报文文件中的行的序列号)
         '0', --上报标志 0-未上报;1-待上报;2-已上报
         '0', --反馈标志 0-未反馈;1-反馈成功;2-反馈失败;3-反馈成功已删除;4-反馈失败已处理;
         '', --行内部门ID
         '21', --操作状态 11-待补录;12-录入中;21-待审核;22-审核通过;23-审核拒绝;30-待校验;31-校验通过;32-校验不通过;
         '12', --报文文件种类 11－借款人基本信息文件 12-信贷业务信息文件 14-不良信贷资产处置信息文件 31-批量信贷业务数据删除请求文件 51-机构基本信息采集报文文件 32-机构基本信息删除报文文件
         '26', --信息记录类型 26-授信业务信息记录
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --金融机构代码
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --分行号
         '', --关联上报报文系统控制号
         '', --机构基本信息采集和删除反馈标志 0-同时反馈 1-至少有一个未反馈
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --录入时间
         'MIGRATION', --录入操作员
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --复核时间
         'MIGRATION', --复核操作员
         '', --复核附言
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --最后更新时间
         'MIGRATION', --最后更新者
         '0', --变更删除标志 0-正常 1-删除 2-业务标识号变更
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '', --人行处理状态,暂时废弃不用
         '18', --报文类型 18－公开授信信息采集报文
         '', --反馈报文信息记录编号
         '', --报文起始位置
         '', --报文终止位置
         '', --预留字段1
         'MIGRATION20160929048', --移植数据标志
         '', --预留字段3
         '', --预留字段4
         '', --预留字段5
         '',
         REPLACE(B.YWDATE, '-')
    FROM (SELECT PBOC_BRANCH, REPORTING_BRANCH
            FROM (SELECT T.REPORTING_BRANCH,
                         T.PBOC_BRANCH,
                         ROW_NUMBER() OVER(PARTITION BY T.PBOC_BRANCH ORDER BY T.PBOC_BRANCH, T.REPORTING_BRANCH) RN
                    FROM CCI_PARAM_ETL_STD_BRANCH T)
           WHERE RN = 1) A,
         MBT_OS_OPENAWARDTRUSTS B
   WHERE A.PBOC_BRANCH = B.ORGCODE AND B.END_DATE > '2017-05-12';
COMMIT;


------------------------------------------
--机构基础信息数据移植
------------------------------------------
DELETE FROM CCI_ORGINFO_BASIC T
 WHERE T.RSV_02 = 'MIGRATION20160929033';
DELETE FROM CCI_REPORT_SYSTEM_CTL T
 WHERE T.RSV_02 = 'MIGRATION20160929033';
COMMIT;
--插入机构基础信息待补录表数据
INSERT INTO CCI_ORGINFO_BASIC
  (SYS_CTL_ID,
   MANAGEMENT_ROW_CODE,
   CUSTOMER_TYPE,
   ORG_CREDIT_CODE_A,
   ORG_CODE_A,
   REGISTRATION_CODE_TYPE_A,
   REGISTRATION_CODE_A,
   TAX_IDENTIFY_CODE_NA,
   TAX_IDENTIFY_CODE_ST,
   OPEN_ACCOUNT_APPROVAL_NO,
   LOAN_CARD_NO,
   DATA_ABSTRACT_DATE,
   RSV_A,
   CUSTOMER_CODE,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0330000' || ORGCODE ||
         LPAD(ID, 6, '0'), --上报报文系统控制号
         '',
         '',
         '',
         CERTIFY_CODE,
         REGIST_TYPE,
         REGIST_CODE,
         GSH_LOGIN_NO,
         DSH_LOGIN_N,
         '',
         CARD_NO,
         REPLACE(YWDATE, '-'),
         '',
         '', --客户号
         '', --备用字段1
         'MIGRATION20160929033', --移植数据标志
         '', --备用字段3
         '', --备用字段4
         '', --备用字段5
         '' --备用字段6
    FROM MBT_OS_BORROWERS T;

--插入机构基础信息对应控制表数据
INSERT INTO CCI_REPORT_SYSTEM_CTL
  (SYS_CTL_ID,
   FILE_SEND_DATE,
   REPORT_BATCH_NO,
   MSG_RECORD_TRACKING_NO,
   MSG_RECORD_OPERATE_TYPE,
   MSG_RECORD_ROW,
   REPORT_FLAG,
   FEEDBACK_FLAG,
   DEPT_ID,
   OPERATING_STATE,
   REPORT_FILE_TYPE,
   MSG_RECORD_TYPE,
   BRANCH_ID,
   BRANCH_NO,
   RELATION_SYS_CTL_ID,
   ORG_BASIC_FEEDBACK_FLAG,
   OPERATE_TIME,
   OPERATER,
   CHECK_TIME,
   CHECK_OPERATOR,
   CHECK_ADD_MSG,
   LAST_UPDATE_TIME,
   LAST_UPDATER,
   LOGIC_DELETE_FLAG,
   DTL_NUM_A,
   DTL_NUM_B,
   DTL_NUM_C,
   DTL_NUM_D,
   RECORD_STATUS_FLAG,
   MESSAGE_TYPE,
   RELATION_FEEDBACK_ID,
   START_INDEX,
   END_INDEX,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06,
   CTL_BUSI_DATE)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0330000' || B.ORGCODE ||
         LPAD(ID, 6, '0'), --上报报文系统控制号
         REPLACE(B.RPTDATE, '-'), --上报日期
         '', --上报批次号
         B.TRACENO, --信息记录跟踪编号
         '1', --信息记录操作类型 1-正常 4-删除
         '', --记录行号(在报文文件中的行的序列号)
         '0', --上报标志 0-未上报;1-待上报;2-已上报
         '0', --反馈标志 0-未反馈;1-反馈成功;2-反馈失败;3-反馈成功已删除;4-反馈失败已处理;
         '', --行内部门ID
         '21', --操作状态 11-待补录;12-录入中;21-待审核;22-审核通过;23-审核拒绝;30-待校验;31-校验通过;32-校验不通过;
         '51', --报文文件种类 11－借款人基本信息文件 12-信贷业务信息文件 14-不良信贷资产处置信息文件 31-批量信贷业务数据删除请求文件 51-机构基本信息采集报文文件 32-机构基本信息删除报文文件
         '01', --信息记录类型 01-机构基础信息记录
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --金融机构代码
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --分行号
         '', --关联上报报文系统控制号
         '', --机构基本信息采集和删除反馈标志 0-同时反馈 1-至少有一个未反馈
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --录入时间
         'MIGRATION', --录入操作员
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --复核时间
         'MIGRATION', --复核操作员
         '', --复核附言
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --最后更新时间
         'MIGRATION', --最后更新者
         '0', --变更删除标志 0-正常 1-删除 2-业务标识号变更
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '', --人行处理状态,暂时废弃不用
         '0', --报文类型
         '', --反馈报文信息记录编号
         '', --报文起始位置
         '', --报文终止位置
         '', --预留字段1
         'MIGRATION20160929033', --移植数据标志
         '', --预留字段3
         '', --预留字段4
         '', --预留字段5
         '',
         REPLACE(B.YWDATE, '-')
    FROM (SELECT PBOC_BRANCH, REPORTING_BRANCH
            FROM (SELECT T.REPORTING_BRANCH,
                         T.PBOC_BRANCH,
                         ROW_NUMBER() OVER(PARTITION BY T.PBOC_BRANCH ORDER BY T.PBOC_BRANCH, T.REPORTING_BRANCH) RN
                    FROM CCI_PARAM_ETL_STD_BRANCH T)
           WHERE RN = 1) A,
         MBT_OS_BORROWERS B
   WHERE A.PBOC_BRANCH = B.ORGCODE;
COMMIT;


------------------------------------------
--机构基本属性信息数据移植
------------------------------------------
DELETE FROM CCI_ORGINFO_BASIC_PROPERTY T
 WHERE T.RSV_02 = 'MIGRATION20160929034';
DELETE FROM CCI_REPORT_SYSTEM_CTL T
 WHERE T.RSV_02 = 'MIGRATION20160929034';
COMMIT;
--插入机构基本属性信息待补录表数据
INSERT INTO CCI_ORGINFO_BASIC_PROPERTY
  (SYS_CTL_ID,
   ORG_CN_NAME,
   ORG_EN_NAME,
   REGISTATION_ADDRESS,
   NATIONNALITY,
   REGISTATION_AREA_DIVISION,
   ESTABLISH_DATE,
   PAPER_EXPIRY_DATE,
   OPERATING_RANGE,
   REGISTERED_CAPITAL_CURRENCY,
   REGISTERED_AMOUNT,
   ORG_TYPE,
   ORG_TYPE_CLASSIFY,
   ECONOMIC_CLASSIFY,
   ECONOMIC_TYPE,
   INFORMATION_UPDATE_DATE_B,
   RSV_B,
   CUSTOMER_CODE,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0340000' || T1.ORGCODE ||
         LPAD(T1.ID, 6, '0'), --上报报文系统控制号
         T1.NAME_CN,
		 T1.NAME_UCN,
		 T1.JKR_REGIST_ADDR,
		 T1.COUNTRY,
		 T1.DISTRICT_CODE,
		 T1.JKR_CREATE_YEAR,
		 REPLACE(T1.LICENCE_MATURITY, '-'),
		 '',
		 T2.MONEY_KIND,
		 T2.MONEY,
		 '',
		 '',
		 T1.TRADE_CODE,
		 '',
		 REPLACE(T1.YWDATE, '-'),
		 '',
         '', --客户号
         '', --备用字段1
         'MIGRATION20160929034', --移植数据标志
         '', --备用字段3
         '', --备用字段4
         '', --备用字段5
         '' --备用字段6
    FROM MBT_OS_BORROWERS T1, MBT_OS_REGCAPITALS T2
    WHERE T1.CARD_NO = T2.CARD_NO;

--插入机构基本属性信息对应控制表数据
INSERT INTO CCI_REPORT_SYSTEM_CTL
  (SYS_CTL_ID,
   FILE_SEND_DATE,
   REPORT_BATCH_NO,
   MSG_RECORD_TRACKING_NO,
   MSG_RECORD_OPERATE_TYPE,
   MSG_RECORD_ROW,
   REPORT_FLAG,
   FEEDBACK_FLAG,
   DEPT_ID,
   OPERATING_STATE,
   REPORT_FILE_TYPE,
   MSG_RECORD_TYPE,
   BRANCH_ID,
   BRANCH_NO,
   RELATION_SYS_CTL_ID,
   ORG_BASIC_FEEDBACK_FLAG,
   OPERATE_TIME,
   OPERATER,
   CHECK_TIME,
   CHECK_OPERATOR,
   CHECK_ADD_MSG,
   LAST_UPDATE_TIME,
   LAST_UPDATER,
   LOGIC_DELETE_FLAG,
   DTL_NUM_A,
   DTL_NUM_B,
   DTL_NUM_C,
   DTL_NUM_D,
   RECORD_STATUS_FLAG,
   MESSAGE_TYPE,
   RELATION_FEEDBACK_ID,
   START_INDEX,
   END_INDEX,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06,
   CTL_BUSI_DATE)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0340000' || B.ORGCODE ||
         LPAD(B.ID, 6, '0'), --上报报文系统控制号
         REPLACE(B.RPTDATE, '-'), --上报日期
         '', --上报批次号
         B.TRACENO, --信息记录跟踪编号
         '1', --信息记录操作类型 1-正常 4-删除
         '', --记录行号(在报文文件中的行的序列号)
         '0', --上报标志 0-未上报;1-待上报;2-已上报
         '0', --反馈标志 0-未反馈;1-反馈成功;2-反馈失败;3-反馈成功已删除;4-反馈失败已处理;
         '', --行内部门ID
         '21', --操作状态 11-待补录;12-录入中;21-待审核;22-审核通过;23-审核拒绝;30-待校验;31-校验通过;32-校验不通过;
         '51', --报文文件种类 11－借款人基本信息文件 12-信贷业务信息文件 14-不良信贷资产处置信息文件 31-批量信贷业务数据删除请求文件 51-机构基本信息采集报文文件 32-机构基本信息删除报文文件
         '43', --信息记录类型 43-机构基本属性信息记录
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --金融机构代码
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --分行号
         '', --关联上报报文系统控制号
         '', --机构基本信息采集和删除反馈标志 0-同时反馈 1-至少有一个未反馈
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --录入时间
         'MIGRATION', --录入操作员
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --复核时间
         'MIGRATION', --复核操作员
         '', --复核附言
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --最后更新时间
         'MIGRATION', --最后更新者
         '0', --变更删除标志 0-正常 1-删除 2-业务标识号变更
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '', --人行处理状态,暂时废弃不用
         '0', --报文类型
         '', --反馈报文信息记录编号
         '', --报文起始位置
         '', --报文终止位置
         '', --预留字段1
         'MIGRATION20160929034', --移植数据标志
         '', --预留字段3
         '', --预留字段4
         '', --预留字段5
         '',
         REPLACE(B.YWDATE, '-')
    FROM (SELECT PBOC_BRANCH, REPORTING_BRANCH
            FROM (SELECT T.REPORTING_BRANCH,
                         T.PBOC_BRANCH,
                         ROW_NUMBER() OVER(PARTITION BY T.PBOC_BRANCH ORDER BY T.PBOC_BRANCH, T.REPORTING_BRANCH) RN
                    FROM CCI_PARAM_ETL_STD_BRANCH T)
           WHERE RN = 1) A,
         MBT_OS_BORROWERS B, MBT_OS_REGCAPITALS C
   WHERE A.PBOC_BRANCH = B.ORGCODE AND B.CARD_NO = C.CARD_NO;
COMMIT;


------------------------------------------
--机构状态信息数据移植
------------------------------------------
DELETE FROM CCI_ORGINFO_ORG_STATUS T
 WHERE T.RSV_02 = 'MIGRATION20160929042';
DELETE FROM CCI_REPORT_SYSTEM_CTL T
 WHERE T.RSV_02 = 'MIGRATION20160929042';
COMMIT;
--插入机构状态信息待补录表数据
INSERT INTO CCI_ORGINFO_ORG_STATUS
  (SYS_CTL_ID,
   BASIC_STATUS,
   ENTERPRISE_SCALE,
   ORG_STATUS,
   INFORMATION_UPDATE_DATE_D,
   RSV_D,
   CUSTOMER_CODE,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0420000' || ORGCODE ||
         LPAD(ID, 6, '0'), --上报报文系统控制号
		 ''        ,
		 JKR_INPRESS,
		 '',
		 REPLACE(YWDATE, '-'),
		 '',
         '', --客户号
         '', --备用字段1
         'MIGRATION20160929042', --移植数据标志
         '', --备用字段3
         '', --备用字段4
         '', --备用字段5
         '' --备用字段6
    FROM MBT_OS_BORROWERS T;

--插入机构状态信息对应控制表数据
INSERT INTO CCI_REPORT_SYSTEM_CTL
  (SYS_CTL_ID,
   FILE_SEND_DATE,
   REPORT_BATCH_NO,
   MSG_RECORD_TRACKING_NO,
   MSG_RECORD_OPERATE_TYPE,
   MSG_RECORD_ROW,
   REPORT_FLAG,
   FEEDBACK_FLAG,
   DEPT_ID,
   OPERATING_STATE,
   REPORT_FILE_TYPE,
   MSG_RECORD_TYPE,
   BRANCH_ID,
   BRANCH_NO,
   RELATION_SYS_CTL_ID,
   ORG_BASIC_FEEDBACK_FLAG,
   OPERATE_TIME,
   OPERATER,
   CHECK_TIME,
   CHECK_OPERATOR,
   CHECK_ADD_MSG,
   LAST_UPDATE_TIME,
   LAST_UPDATER,
   LOGIC_DELETE_FLAG,
   DTL_NUM_A,
   DTL_NUM_B,
   DTL_NUM_C,
   DTL_NUM_D,
   RECORD_STATUS_FLAG,
   MESSAGE_TYPE,
   RELATION_FEEDBACK_ID,
   START_INDEX,
   END_INDEX,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06,
   CTL_BUSI_DATE)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0420000' || B.ORGCODE ||
         LPAD(ID, 6, '0'), --上报报文系统控制号
         REPLACE(B.RPTDATE, '-'), --上报日期
         '', --上报批次号
         B.TRACENO, --信息记录跟踪编号
         '1', --信息记录操作类型 1-正常 4-删除
         '', --记录行号(在报文文件中的行的序列号)
         '0', --上报标志 0-未上报;1-待上报;2-已上报
         '0', --反馈标志 0-未反馈;1-反馈成功;2-反馈失败;3-反馈成功已删除;4-反馈失败已处理;
         '', --行内部门ID
         '21', --操作状态 11-待补录;12-录入中;21-待审核;22-审核通过;23-审核拒绝;30-待校验;31-校验通过;32-校验不通过;
         '51', --报文文件种类 11－借款人基本信息文件 12-信贷业务信息文件 14-不良信贷资产处置信息文件 31-批量信贷业务数据删除请求文件 51-机构基本信息采集报文文件 32-机构基本信息删除报文文件
         '45', --信息记录类型 33-机构状态信息记录
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --金融机构代码
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --分行号
         '', --关联上报报文系统控制号
         '', --机构基本信息采集和删除反馈标志 0-同时反馈 1-至少有一个未反馈
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --录入时间
         'MIGRATION', --录入操作员
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --复核时间
         'MIGRATION', --复核操作员
         '', --复核附言
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --最后更新时间
         'MIGRATION', --最后更新者
         '0', --变更删除标志 0-正常 1-删除 2-业务标识号变更
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '', --人行处理状态,暂时废弃不用
         '0', --报文类型
         '', --反馈报文信息记录编号
         '', --报文起始位置
         '', --报文终止位置
         '', --预留字段1
         'MIGRATION20160929042', --移植数据标志
         '', --预留字段3
         '', --预留字段4
         '', --预留字段5
         '',
         REPLACE(B.YWDATE, '-')
    FROM (SELECT PBOC_BRANCH, REPORTING_BRANCH
            FROM (SELECT T.REPORTING_BRANCH,
                         T.PBOC_BRANCH,
                         ROW_NUMBER() OVER(PARTITION BY T.PBOC_BRANCH ORDER BY T.PBOC_BRANCH, T.REPORTING_BRANCH) RN
                    FROM CCI_PARAM_ETL_STD_BRANCH T)
           WHERE RN = 1) A,
         MBT_OS_BORROWERS B
   WHERE A.PBOC_BRANCH = B.ORGCODE;
COMMIT;


------------------------------------------
--机构联络信息数据移植
------------------------------------------
DELETE FROM CCI_ORGINFO_CONTACT T
 WHERE T.RSV_02 = 'MIGRATION20160929035';
DELETE FROM CCI_REPORT_SYSTEM_CTL T
 WHERE T.RSV_02 = 'MIGRATION20160929035';
COMMIT;
--插入机构联络信息待补录表数据
INSERT INTO CCI_ORGINFO_CONTACT
  (SYS_CTL_ID,
   ORG_WORK_ADDRESS,
   TELEPHONE,
   FINANCE_DEPARTMENT_TELEPHONE,
   INFORMATION_UPDATE_DATE_C,
   RSV_C,
   CUSTOMER_CODE,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0350000' || T1.ORGCODE ||
         LPAD(T1.ID, 6, '0'), --上报报文系统控制号
		 T1.JKR_COMM_ADDR,
		 T1.JKR_PHONE,
		 T2.FINANCE_LINK_MODE,
		 REPLACE(T1.YWDATE, '-'),
		 '',
         '', --客户号
         '', --备用字段1
         'MIGRATION20160929035', --移植数据标志
         '', --备用字段3
         '', --备用字段4
         '', --备用字段5
         '' --备用字段6
    FROM MBT_OS_BORROWERS T1, MBT_OS_FINANCECONTACTS T2
    WHERE T1.CARD_NO = T2.CARD_NO;

--插入机构联络信息对应控制表数据
INSERT INTO CCI_REPORT_SYSTEM_CTL
  (SYS_CTL_ID,
   FILE_SEND_DATE,
   REPORT_BATCH_NO,
   MSG_RECORD_TRACKING_NO,
   MSG_RECORD_OPERATE_TYPE,
   MSG_RECORD_ROW,
   REPORT_FLAG,
   FEEDBACK_FLAG,
   DEPT_ID,
   OPERATING_STATE,
   REPORT_FILE_TYPE,
   MSG_RECORD_TYPE,
   BRANCH_ID,
   BRANCH_NO,
   RELATION_SYS_CTL_ID,
   ORG_BASIC_FEEDBACK_FLAG,
   OPERATE_TIME,
   OPERATER,
   CHECK_TIME,
   CHECK_OPERATOR,
   CHECK_ADD_MSG,
   LAST_UPDATE_TIME,
   LAST_UPDATER,
   LOGIC_DELETE_FLAG,
   DTL_NUM_A,
   DTL_NUM_B,
   DTL_NUM_C,
   DTL_NUM_D,
   RECORD_STATUS_FLAG,
   MESSAGE_TYPE,
   RELATION_FEEDBACK_ID,
   START_INDEX,
   END_INDEX,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06,
   CTL_BUSI_DATE)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0350000' || B.ORGCODE ||
         LPAD(B.ID, 6, '0'), --上报报文系统控制号
         REPLACE(B.RPTDATE, '-'), --上报日期
         '', --上报批次号
         B.TRACENO, --信息记录跟踪编号
         '1', --信息记录操作类型 1-正常 4-删除
         '', --记录行号(在报文文件中的行的序列号)
         '0', --上报标志 0-未上报;1-待上报;2-已上报
         '0', --反馈标志 0-未反馈;1-反馈成功;2-反馈失败;3-反馈成功已删除;4-反馈失败已处理;
         '', --行内部门ID
         '21', --操作状态 11-待补录;12-录入中;21-待审核;22-审核通过;23-审核拒绝;30-待校验;31-校验通过;32-校验不通过;
         '51', --报文文件种类 11－借款人基本信息文件 12-信贷业务信息文件 14-不良信贷资产处置信息文件 31-批量信贷业务数据删除请求文件 51-机构基本信息采集报文文件 32-机构基本信息删除报文文件
         '44', --信息记录类型 44-机构联络信息记录
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --金融机构代码
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --分行号
         '', --关联上报报文系统控制号
         '', --机构基本信息采集和删除反馈标志 0-同时反馈 1-至少有一个未反馈
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --录入时间
         'MIGRATION', --录入操作员
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --复核时间
         'MIGRATION', --复核操作员
         '', --复核附言
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --最后更新时间
         'MIGRATION', --最后更新者
         '0', --变更删除标志 0-正常 1-删除 2-业务标识号变更
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '', --人行处理状态,暂时废弃不用
         '0', --报文类型
         '', --反馈报文信息记录编号
         '', --报文起始位置
         '', --报文终止位置
         '', --预留字段1
         'MIGRATION20160929035', --移植数据标志
         '', --预留字段3
         '', --预留字段4
         '', --预留字段5
         '',
         REPLACE(B.YWDATE, '-')
    FROM (SELECT PBOC_BRANCH, REPORTING_BRANCH
            FROM (SELECT T.REPORTING_BRANCH,
                         T.PBOC_BRANCH,
                         ROW_NUMBER() OVER(PARTITION BY T.PBOC_BRANCH ORDER BY T.PBOC_BRANCH, T.REPORTING_BRANCH) RN
                    FROM CCI_PARAM_ETL_STD_BRANCH T)
           WHERE RN = 1) A,
         MBT_OS_BORROWERS B, MBT_OS_FINANCECONTACTS C
   WHERE A.PBOC_BRANCH = B.ORGCODE AND B.CARD_NO = C.CARD_NO;
COMMIT;


------------------------------------------
--机构高管信息数据移植
------------------------------------------
DELETE FROM CCI_ORGINFO_EXECUTIVE_RELA T
 WHERE T.RSV_02 = 'MIGRATION20160929037';
DELETE FROM CCI_REPORT_SYSTEM_CTL T
 WHERE T.RSV_02 = 'MIGRATION20160929037';
COMMIT;
--插入机构高管信息待补录表数据
INSERT INTO CCI_ORGINFO_EXECUTIVE_RELA
  (SYS_CTL_ID,
   RELATION_PARTY_TYPE,
   NAME,
   PAPER_TYPE,
   PAPER_CODE,
   INFORMATION_UPDATE_DATE,
   CUSTOMER_CODE,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0370000' || T1.ORGCODE ||
         LPAD(T1.ID, 6, '0'), --上报报文系统控制号
		 T1.SUPER_KIND,
		 T1.SUPER_NAME,
		 T1.CERTIFY_TYPE,
		 T1.CERTIFY_CODE,
		 REPLACE(T2.YWDATE, '-'),
         '', --客户号
         '', --备用字段1
         'MIGRATION20160929037', --移植数据标志
         '', --备用字段3
         '', --备用字段4
         '', --备用字段5
         '' --备用字段6
    FROM MBT_OS_SUPERMANS T1, MBT_OS_BORROWERS T2
    WHERE T1.CARD_NO = T2.CARD_NO;

--插入机构高管信息对应控制表数据
INSERT INTO CCI_REPORT_SYSTEM_CTL
  (SYS_CTL_ID,
   FILE_SEND_DATE,
   REPORT_BATCH_NO,
   MSG_RECORD_TRACKING_NO,
   MSG_RECORD_OPERATE_TYPE,
   MSG_RECORD_ROW,
   REPORT_FLAG,
   FEEDBACK_FLAG,
   DEPT_ID,
   OPERATING_STATE,
   REPORT_FILE_TYPE,
   MSG_RECORD_TYPE,
   BRANCH_ID,
   BRANCH_NO,
   RELATION_SYS_CTL_ID,
   ORG_BASIC_FEEDBACK_FLAG,
   OPERATE_TIME,
   OPERATER,
   CHECK_TIME,
   CHECK_OPERATOR,
   CHECK_ADD_MSG,
   LAST_UPDATE_TIME,
   LAST_UPDATER,
   LOGIC_DELETE_FLAG,
   DTL_NUM_A,
   DTL_NUM_B,
   DTL_NUM_C,
   DTL_NUM_D,
   RECORD_STATUS_FLAG,
   MESSAGE_TYPE,
   RELATION_FEEDBACK_ID,
   START_INDEX,
   END_INDEX,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06,
   CTL_BUSI_DATE)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0370000' || B.ORGCODE ||
         LPAD(C.ID, 6, '0'), --上报报文系统控制号
         REPLACE(B.RPTDATE, '-'), --上报日期
         '', --上报批次号
         B.TRACENO, --信息记录跟踪编号
         '1', --信息记录操作类型 1-正常 4-删除
         '', --记录行号(在报文文件中的行的序列号)
         '0', --上报标志 0-未上报;1-待上报;2-已上报
         '0', --反馈标志 0-未反馈;1-反馈成功;2-反馈失败;3-反馈成功已删除;4-反馈失败已处理;
         '', --行内部门ID
         '21', --操作状态 11-待补录;12-录入中;21-待审核;22-审核通过;23-审核拒绝;30-待校验;31-校验通过;32-校验不通过;
         '51', --报文文件种类 11－借款人基本信息文件 12-信贷业务信息文件 14-不良信贷资产处置信息文件 31-批量信贷业务数据删除请求文件 51-机构基本信息采集报文文件 32-机构基本信息删除报文文件
         '40', --信息记录类型 40-机构高管信息记录
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --金融机构代码
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --分行号
         '', --关联上报报文系统控制号
         '', --机构基本信息采集和删除反馈标志 0-同时反馈 1-至少有一个未反馈
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --录入时间
         'MIGRATION', --录入操作员
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --复核时间
         'MIGRATION', --复核操作员
         '', --复核附言
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --最后更新时间
         'MIGRATION', --最后更新者
         '0', --变更删除标志 0-正常 1-删除 2-业务标识号变更
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '', --人行处理状态,暂时废弃不用
         '0', --报文类型
         '', --反馈报文信息记录编号
         '', --报文起始位置
         '', --报文终止位置
         '', --预留字段1
         'MIGRATION20160929037', --移植数据标志
         '', --预留字段3
         '', --预留字段4
         '', --预留字段5
         '',
         REPLACE(B.YWDATE, '-')
    FROM (SELECT PBOC_BRANCH, REPORTING_BRANCH
            FROM (SELECT T.REPORTING_BRANCH,
                         T.PBOC_BRANCH,
                         ROW_NUMBER() OVER(PARTITION BY T.PBOC_BRANCH ORDER BY T.PBOC_BRANCH, T.REPORTING_BRANCH) RN
                    FROM CCI_PARAM_ETL_STD_BRANCH T)
           WHERE RN = 1) A,
         MBT_OS_BORROWERS B, MBT_OS_SUPERMANS C
   WHERE A.PBOC_BRANCH = B.ORGCODE AND B.CARD_NO = C.CARD_NO;
COMMIT;


------------------------------------------
--机构上级机构（主管单位）信息数据移植
------------------------------------------
DELETE FROM CCI_ORGINFO_IMPORT_S_H T
 WHERE T.RSV_02 = 'MIGRATION20160929043';
DELETE FROM CCI_REPORT_SYSTEM_CTL T
 WHERE T.RSV_02 = 'MIGRATION20160929043';
COMMIT;
--机构上级机构（主管单位）信息待补录表数据
INSERT INTO CCI_ORGINFO_IMPORT_S_H
  (SYS_CTL_ID,
   SUPERIOR_ORG_NAME,
   REGISTRATION_CODE_TYPE_E,
   REGISTRATION_CODE_E,
   ORG_CODE_E,
   ORG_CREDIT_CODE_E,
   INFORMATION_UPDATE_DATE_E,
   RSV_E,
   CUSTOMER_CODE,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0430000' || T1.ORGCODE ||
         LPAD(T1.ID, 6, '0'), --上报报文系统控制号
		 SUPER_NAME,
		 '',
		 '',
		 SUPER_ORGCODE,
		 '',
		 REPLACE(T2.YWDATE, '-'),
		 '',
         '', --客户号
         '', --备用字段1
         'MIGRATION20160929043', --移植数据标志
         '', --备用字段3
         '', --备用字段4
         '', --备用字段5
         '' --备用字段6
    FROM MBT_OS_GRPCORPS T1, MBT_OS_BORROWERS T2
    WHERE T1.CARD_NO = T2.CARD_NO;

--插入机构上级机构（主管单位）信息对应控制表数据
INSERT INTO CCI_REPORT_SYSTEM_CTL
  (SYS_CTL_ID,
   FILE_SEND_DATE,
   REPORT_BATCH_NO,
   MSG_RECORD_TRACKING_NO,
   MSG_RECORD_OPERATE_TYPE,
   MSG_RECORD_ROW,
   REPORT_FLAG,
   FEEDBACK_FLAG,
   DEPT_ID,
   OPERATING_STATE,
   REPORT_FILE_TYPE,
   MSG_RECORD_TYPE,
   BRANCH_ID,
   BRANCH_NO,
   RELATION_SYS_CTL_ID,
   ORG_BASIC_FEEDBACK_FLAG,
   OPERATE_TIME,
   OPERATER,
   CHECK_TIME,
   CHECK_OPERATOR,
   CHECK_ADD_MSG,
   LAST_UPDATE_TIME,
   LAST_UPDATER,
   LOGIC_DELETE_FLAG,
   DTL_NUM_A,
   DTL_NUM_B,
   DTL_NUM_C,
   DTL_NUM_D,
   RECORD_STATUS_FLAG,
   MESSAGE_TYPE,
   RELATION_FEEDBACK_ID,
   START_INDEX,
   END_INDEX,
   RSV_01,
   RSV_02,
   RSV_03,
   RSV_04,
   RSV_05,
   RSV_06,
   CTL_BUSI_DATE)
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') || '0430000' || B.ORGCODE ||
         LPAD(C.ID, 6, '0'), --上报报文系统控制号
         REPLACE(B.RPTDATE, '-'), --上报日期
         '', --上报批次号
         B.TRACENO, --信息记录跟踪编号
         '1', --信息记录操作类型 1-正常 4-删除
         '', --记录行号(在报文文件中的行的序列号)
         '0', --上报标志 0-未上报;1-待上报;2-已上报
         '0', --反馈标志 0-未反馈;1-反馈成功;2-反馈失败;3-反馈成功已删除;4-反馈失败已处理;
         '', --行内部门ID
         '21', --操作状态 11-待补录;12-录入中;21-待审核;22-审核通过;23-审核拒绝;30-待校验;31-校验通过;32-校验不通过;
         '51', --报文文件种类 11－借款人基本信息文件 12-信贷业务信息文件 14-不良信贷资产处置信息文件 31-批量信贷业务数据删除请求文件 51-机构基本信息采集报文文件 32-机构基本信息删除报文文件
         '46', --信息记录类型 46-机构上级机构（主管单位）信息记录
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --金融机构代码
         NVL(A.REPORTING_BRANCH, A.PBOC_BRANCH), --分行号
         '', --关联上报报文系统控制号
         '', --机构基本信息采集和删除反馈标志 0-同时反馈 1-至少有一个未反馈
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --录入时间
         'MIGRATION', --录入操作员
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --复核时间
         'MIGRATION', --复核操作员
         '', --复核附言
         TO_CHAR(SYSDATE, 'YYYYMMDDHH24DDMM'), --最后更新时间
         'MIGRATION', --最后更新者
         '0', --变更删除标志 0-正常 1-删除 2-业务标识号变更
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '0', --审核用,暂时废弃不用，默认赋值为0
         '', --人行处理状态,暂时废弃不用
         '0', --报文类型
         '', --反馈报文信息记录编号
         '', --报文起始位置
         '', --报文终止位置
         '', --预留字段1
         'MIGRATION20160929043', --移植数据标志
         '', --预留字段3
         '', --预留字段4
         '', --预留字段5
         '',
         REPLACE(B.YWDATE, '-')
    FROM (SELECT PBOC_BRANCH, REPORTING_BRANCH
            FROM (SELECT T.REPORTING_BRANCH,
                         T.PBOC_BRANCH,
                         ROW_NUMBER() OVER(PARTITION BY T.PBOC_BRANCH ORDER BY T.PBOC_BRANCH, T.REPORTING_BRANCH) RN
                    FROM CCI_PARAM_ETL_STD_BRANCH T)
           WHERE RN = 1) A,
         MBT_OS_BORROWERS B, MBT_OS_GRPCORPS C
   WHERE A.PBOC_BRANCH = B.ORGCODE AND B.CARD_NO = C.CARD_NO;
COMMIT;
