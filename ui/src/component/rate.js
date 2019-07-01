import React from 'react';
import { 
    Card,
    List,
    Button,
    Accordion,
    Form,
    Icon
} from 'semantic-ui-react'
import Axios from 'axios';
import isNumber from 'is-number';


class DefaultList extends React.Component {

    state = {
      activeIndex: -1,
      newRate: "",
      loading: false
    }

    componentDidMount () {
        const { rate } = this.props;
        this.setState({
            newRate: rate.Record.rate
        })
    }

    handleClick = (e, titleProps) => {
        const { index } = titleProps
        const { activeIndex } = this.state
        const newIndex = activeIndex === index ? -1 : index
    
        this.setState({ activeIndex: newIndex })
      }

    handleChange = (e) => {
        this.setState({
            [e.target.name]: e.target.value
        })
    }

    updateRate = () => {
        const { rate, getRate } = this.props;
        const { newRate } = this.state

        if (newRate.length > 0 && isNumber(newRate) ) {
            this.setState({
                loading: true
            })
            Axios.put(`/rate/${rate.Record.id}`, {
                rate: newRate
            }).then((response) => {
                this.setState({
                  newRate: "",
                  activeIndex: -1,
                });
                getRate();
              }).catch(err => {
                console.log(err)
              }).finally(()=> {
                this.setState({
                    loading: false
                })
              })
        }
    }

    render () {
        const { rate } = this.props;
        const { activeIndex, newRate, loading } = this.state;
    

        return (
            <Card>
                <Card.Content>
                <Card.Header>{rate.Record.name}</Card.Header>
                <Card.Description>
                    <List>
                        <List.Item>Id: {rate.Record.id}</List.Item>
                        <List.Item>From: {rate.Record.from}</List.Item>
                        <List.Item>To: {rate.Record.to}</List.Item>
                        <List.Item>Rate: {rate.Record.rate}</List.Item>
                    </List>
                </Card.Description>
                </Card.Content>
                <Card.Content extra>
                    <Accordion>
                        <Accordion.Title active={activeIndex === 0} index={0} onClick={this.handleClick}>
                            <Icon name='dropdown' />
                            요율변경
                        </Accordion.Title>
                        <Accordion.Content active={activeIndex === 0}>
                            <Form>
                            <Form.Group>
                                <Form.Input label='요율' name="newRate" value={newRate} placeholder='%' onChange={this.handleChange} />
                            </Form.Group>
                            <Button secondary onClick={this.updateRate} loading={loading}>Update</Button>
                            </Form>
                        </Accordion.Content>
                    </Accordion>
                </Card.Content>
            </Card>
        );
    }
}
   

export default DefaultList;