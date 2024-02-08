// index.ts
import { Router } from 'express';
import statistics from './statistics';

const router = Router();

router.use('/api/statistics', statistics);

export default router;