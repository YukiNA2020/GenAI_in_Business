const aiService = require('./ai.service');
const { AiProviderError } = require('./ai.provider');
const { AI_ERROR_CODES, STORY_STYLES } = require('./ai.schemas');

function statusForAiError(code) {
  if (code === AI_ERROR_CODES.validation) {
    return 400;
  }
  return 502;
}

function validateAiBody(schema, response) {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      const first = result.error.issues[0];
      const message = first?.message || 'description is required';
      return response.error(res, AI_ERROR_CODES.validation, message, 400);
    }
    req.validatedBody = result.data;
    next();
  };
}

function createAiRouter({ Router, z, response }) {
  const router = Router();

  const baseBodySchema = {
    title: z.string().optional(),
    category: z.string().optional(),
    location: z.string().optional(),
    dateAcquired: z.string().optional(),
    description: z
      .string({ required_error: 'description is required' })
      .min(1, 'description is required'),
    imageDescription: z.string().optional(),
    imageUrl: z.string().optional(),
    language: z.string().optional(),
    style: z.enum(STORY_STYLES).optional(),
  };

  const aiBodySchema = z.object(baseBodySchema);
  const validate = validateAiBody(aiBodySchema, response);

  const analyzeImageBodySchema = z
    .object({
      imageDescription: z.string().optional(),
      imageUrl: z.string().optional(),
      imageDataUrl: z.string().optional(),
      language: z.string().optional(),
    })
    .superRefine((body, ctx) => {
      const hasDesc =
        typeof body.imageDescription === 'string' && body.imageDescription.trim().length > 0;
      const hasUrl = typeof body.imageUrl === 'string' && body.imageUrl.trim().length > 0;
      const hasDataUrl =
        typeof body.imageDataUrl === 'string' && body.imageDataUrl.trim().length > 0;
      if (!hasDesc && !hasUrl && !hasDataUrl) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: 'imageDescription, imageUrl or imageDataUrl is required',
          path: ['imageDescription'],
        });
      }
      // Validate imageDataUrl format before the provider checks MIME and size.
      if (hasDataUrl && !body.imageDataUrl.startsWith('data:image/')) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: 'imageDataUrl must be a data URL (data:image/...)',
          path: ['imageDataUrl'],
        });
      }
    });
  const validateAnalyzeImage = validateAiBody(analyzeImageBodySchema, response);

  function wrapAi(handler) {
    return async (req, res, next) => {
      try {
        const data = await handler(req.validatedBody);
        return response.success(res, data);
      } catch (error) {
        if (error instanceof AiProviderError) {
          return response.error(
            res,
            error.code,
            error.message,
            statusForAiError(error.code)
          );
        }
        return next(error);
      }
    };
  }

  router.post(
    '/suggest-title',
    validate,
    wrapAi((body) => aiService.suggestTitle(body))
  );

  router.post(
    '/suggest-category',
    validate,
    wrapAi((body) => aiService.suggestCategory(body))
  );

  router.post(
    '/suggest-tags',
    validate,
    wrapAi((body) => aiService.suggestTags(body))
  );

  router.post(
    '/generate-story',
    validate,
    wrapAi((body) => aiService.generateStory(body))
  );

  router.post(
    '/analyze-image',
    validateAnalyzeImage,
    wrapAi((body) => aiService.analyzeImage(body))
  );

  return router;
}

module.exports = { createAiRouter, statusForAiError };
