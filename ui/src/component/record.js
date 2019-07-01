import React from 'react';
import { 
    Message
} from 'semantic-ui-react'

const DeaultRecord = ({record}) => {
    return (
        <Message positive>{`Id: ${record.Record.id}, rateId: ${record.Record.rateId}, rateFee: ${record.Record.rateFee}, Total: ${record.Record.total}, Fee: ${record.Record.fee}`}</Message>
    );
};

export default DeaultRecord;
