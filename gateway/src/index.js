import Koa from "koa";
import KoaBodyParser  from 'koa-bodyparser';
import KoaRouter from "koa-router";
import { getLogger } from 'log4js';
import * as Setcc from "./setcc";

const port = process.env.PORT || 3001;
const logger = getLogger();
logger.level = 'debug';


const app = new Koa();
app.use(KoaBodyParser());

const router = new KoaRouter();
router.get("/rate", Setcc.getRate);
router.get("/rate/:id", Setcc.getRateById);
router.post("/rate", Setcc.createRate);
router.put("/rate/:id", Setcc.updateRate);
router.get("/record", Setcc.getRecord);
router.post("/record", Setcc.createRecord);
router.get("/all", Setcc.getRecord);

app.use(router.routes()).use(router.allowedMethods());


app.listen(port, ()=> {
    logger.info(`Starting setdapp-gateway server port[${port}]`);
})