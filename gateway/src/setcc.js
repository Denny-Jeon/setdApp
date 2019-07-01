import { getLogger } from 'log4js';
import { FileSystemWallet, Gateway  } from "fabric-network";
import fs from "fs";
import path from "path";

const logger = getLogger();
logger.level = 'debug';


const ORG = process.env.ORG || "org1";
const USER = "user1";
const CHANNEL_NAME="setchannel1";
const SMART_CONTRACT = "setcc";

const loadccp = () => {
    try {
        const ccpPath = path.resolve(__dirname, '../connection', `${ORG}_connection.json`);
        const ccpJSON = fs.readFileSync(ccpPath, "utf8");
        const ccp = JSON.parse(ccpJSON);

        return {
            ccpPath,
            ccpJSON,
            ccp
        }
    } catch (e) {
        logger.error("==================== error loadccp =======================")
        logger.error(e);
        logger.error("")       
    }
}

const loadwallet = () => {
    try {
        const walletPath = path.join(path.resolve(__dirname, '../wallet', ORG));
        const wallet = new FileSystemWallet(walletPath);


        return {
            walletPath,
            wallet
        }
    } catch (e) {
        logger.error("==================== error loadwallet =======================")
        logger.error(e);
        logger.error("")       
    }
}




class smartContract {
    constructor () {
        this.gateway = null;
        this.network = null;
        this.constract = null;
    }

    async init () {
        try {
            const ccpInfo = loadccp();
            const walletInfo = loadwallet();

            this.gateway  = new Gateway();
            await this.gateway.connect(ccpInfo.ccp, {
                wallet: walletInfo.wallet,
                identity: USER,
                discovery: {
                    enabled: false
                }
            })

            this.network = await this.gateway.getNetwork(CHANNEL_NAME);
            this.contract = this.network.getContract(SMART_CONTRACT);

        } catch(e) {
            logger.error("==================== error smartContract =======================")
            logger.error(e);
            logger.error("")
        }
    }

    async evaluateTransaction (func, ...args) {
        return await this.contract.evaluateTransaction(func, ...args);
    }

    async submitTransaction (func, ...args) {
        return await this.contract.submitTransaction(func, ...args);
    }
}


export const getRate = async (ctx) => {
    try {
        logger.debug("queryAllRate");

        const setcc = new smartContract(); 
        await setcc.init();

        const results = await setcc.evaluateTransaction("queryAllRate");
        const json = JSON.parse(results.toString());

        ctx.status = 200;
        ctx.body = {
            results: JSON.parse(json)
        };
    } catch(e) {
        ctx.status = 500;
        ctx.body = {
            message: e.message
        }
    }
};

export const getRateById = async (ctx) => {
    try {
        logger.debug("getRateById");

        const id = ctx.params.id;
        const setcc = new smartContract(); 
        await setcc.init();
        
        const results = await setcc.evaluateTransaction("queryRate", id);
        const json = JSON.parse(results.toString());

        ctx.status = 200;
        ctx.body =  JSON.parse(json);
    } catch(e) {
        ctx.status = 500;
        ctx.body = {
            message: e.message
        }
    }
};

export const createRate = async (ctx) => {
    try {
        logger.debug("createRate");

        const newRate = ctx.request.body;
        logger.debug("body: ", ctx.request.body);


        const setcc = new smartContract(); 
        await setcc.init();
        
        const results = await setcc.submitTransaction("createRate", 
                            newRate.name,
                            newRate.from,
                            newRate.to,
                            newRate.rate);
        ctx.status = 200;
        ctx.body= { }
    } catch(e) {
        ctx.status = 500;
        ctx.body = {
            message: e.message
        }
    }
};

export const updateRate = async (ctx) => {
    try {
        logger.debug("updateRate");

        const id = ctx.params.id;

        const newRate = ctx.request.body;
        logger.debug("body: ", ctx.request.body);


        const setcc = new smartContract(); 
        await setcc.init();
        
        const results = await setcc.submitTransaction("changeRate", 
                            id,
                            newRate.rate);
        ctx.status = 200;
        ctx.body= { }
    } catch(e) {
        ctx.status = 500;
        ctx.body = {
            message: e.message
        }
    }
};

export const getRecord = async (ctx) => {
    try {
        logger.debug("getRecord");

        const setcc = new smartContract(); 
        await setcc.init();

        const results = await setcc.evaluateTransaction("queryAllRecord");
        const json = JSON.parse(results.toString());

        ctx.status = 200;
        ctx.body = {
            results: JSON.parse(json)
        };
    } catch(e) {
        ctx.status = 500;
        ctx.body = {
            message: e.message
        }
    }
};

export const createRecord = async (ctx) => {
    try {
        logger.debug("createRecord");

        const newUsage = ctx.request.body;
        logger.debug("body: ", ctx.request.body);


        const setcc = new smartContract(); 
        await setcc.init();
        
        const results = await setcc.submitTransaction("createRecord", 
                        newUsage.rateId,
                        newUsage.usage);
        ctx.status = 200;
        ctx.body= { }
    } catch(e) {
        ctx.status = 500;
        ctx.body = {
            message: e.message
        }
    }
};


export const getAll = async (ctx) => {
    try {
        logger.debug("getALl");

        const setcc = new smartContract(); 
        await setcc.init();

        const results = await setcc.evaluateTransaction("queryALl");
        const json = JSON.parse(results.toString());

        ctx.status = 200;
        ctx.body = {
            results: JSON.parse(json)
        };
    } catch(e) {
        ctx.status = 500;
        ctx.body = {
            message: e.message
        }
    }
};
