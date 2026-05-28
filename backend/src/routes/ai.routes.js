/**
 * 成员 E AI 路由挂载适配层
 * 将 Express / zod / 统一响应注入 member_E 的 createAiRouter，避免在 member_E 内重复依赖解析问题。
 * 负责人：成员 E / 成员 5（挂载适配）；成员 A 的 app.js 仅增加一行 use。
 */
const { Router } = require('express');
const { z } = require('zod');
const response = require('../utils/response');
const { createAiRouter } = require('../../../member_E/backend/src/ai/ai.routes');

module.exports = createAiRouter({ Router, z, response });
