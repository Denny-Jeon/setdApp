import React, { Component } from 'react';
import {
  Grid, 
  Divider, 
  Header, 
  Card,
  Image,
  Button, 
  Form,
  Modal,
  Input,
  Select,
  Message,
  Icon,
  Accordion
} from "semantic-ui-react";
import Axios from 'axios';
import isNumber from 'is-number';

import DefaultRate from "./component/rate";
import DefaultRecord from "./component/record";


class App extends Component {

  state = {
    rateList: [],
    recordList: [],
    activeIndex: -1,
    rateName: "",
    rate: "",
    from: "org1",
    to: "org2",
    rateId: "",
    rateLoading: false,
    recordLoading: false,
  }

  getRate = async () => {
      Axios.get('/rate').then((response) => {
        this.setState({
          rateList: response.data.results
        }, () => {
          console.log(this.state.rateList)
        });
      }).catch(err => {
        console.log(err)
      });
  }

  getRecord = async () => {
    Axios.get('/record').then((response) => {
      this.setState({
        recordList: response.data.results
      }, () => {
        console.log(this.state.recordList)
      });
    }).catch(err => {
      console.log(err)
    });
  }

  createRecord = async () => {
    const { rateId } = this.state;

    if (rateId.length > 0) {
      this.setState({
        recordLoading: true
      })
      Axios.post('/record', {
        rateId,
        usage: Math.floor(Math.random() * 10000001).toString()
      }).then((response) => {
        this.setState({
          rateId: ""
        });
        this.getRecord();
      }).catch(err => {
        console.log(err)
      }).finally(() => {
        this.setState({ recordLoading: false})
      })
    }
  }

  async componentDidMount () {
    await this.getRate();
    await this.getRecord();
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

  addRate = () => {
    const { rateName, rate, from, to } = this.state;

    if (rateName.length > 0  && rate.length > 0 && isNumber(rate) ) {
      this.setState({
        rateLoading: true
      })
      Axios.post('/rate', {
        name: rateName,
        from,
        to,
        rate
      }).then((response) => {
        this.setState({
          rateName: "",
          rate: ""
        });
        this.getRate();
      }).catch(err => {
        console.log(err)
      }).finally(() => {
        this.setState({
          rateLoading: false
        })
      })
    }
  }


  render() {
    const { rateList, recordList, activeIndex, rateName, rate, rateId, rateLoading, recordLoading } = this.state;

    return (


        <Grid container style={{ padding: '5em 0em' }}>
          <Grid.Row>
            <Grid.Column>
              <Header as='h1' dividing>
              블록체인 기반 실시간 기업 간 정산 시스템 프로젝트
              </Header>
            </Grid.Column>
          </Grid.Row>

          <Grid.Row>
            <Grid.Column>
              <Message>
                <Header as='h1'>정산 정보 조회</Header>
                <p>블록체인 기반 실시간 기업 간 정산 시스템 블록체인에 등록된 정산 정보를 조회한다.</p>
                
                <Accordion>
                  <Accordion.Title active={activeIndex === 0} index={0} onClick={this.handleClick}>
                    <Icon name='dropdown' />
                    정산 정보 추가
                  </Accordion.Title>
                  <Accordion.Content active={activeIndex === 0}>
                    <Form>
                      <Form.Group widths={2}>
                        <Form.Input label='요율명' name="rateName" value={rateName} placeholder='testRate001' onChange={this.handleChange}/>
                        <Form.Input label='요율' name="rate" value={rate} placeholder='%' onChange={this.handleChange} />
                      </Form.Group>
                      <Button secondary onClick={this.addRate} loading={rateLoading}>Add</Button>
                    </Form>
                  </Accordion.Content>
                </Accordion>
                <Divider hidden />
                <Card.Group>
                  {rateList.map((rate) => <DefaultRate key={rate.Key} rate={rate} getRate={this.getRate}/>)}
                </Card.Group>
              </Message>
            </Grid.Column>
          </Grid.Row>

          <Grid.Row>
            <Grid.Column>
              <Message>
                <Header as='h1'>
                  정산 내역 조회 
                </Header>
                <Form>
                  <Form.Group>
                    <Form.Field inline>
                      <label>Rating Identifier</label>
                      <Input name="rateId" value={rateId} placeholder='774ff680-931b-11e9-b2ad-b55912c8d579' onChange={this.handleChange} />
                    </Form.Field>
                    <Button icon size="mini" onClick = {()=> this.createRecord()} loading={recordLoading}>
                      <Icon name='add' />
                    </Button>
                    <Button icon size="mini" onClick = {()=> this.getRecord()}>
                        <Icon name='sync' />
                    </Button>
                  </Form.Group>
                </Form>
                {recordList.map((record) => <DefaultRecord key={record.Key} record={record} />)}
              </Message>
            </Grid.Column>
          </Grid.Row>
         
          
          {/* <CreateRate genderOptions={genderOptions}/>


          <Modal trigger={<Button>요율변경</Button>}>
            <Modal.Header>요율변경</Modal.Header>
            <Modal.Content image>
              <Image wrapped size='large' src='https://c.pxhere.com/images/e1/c5/b7749c3de841aac333779a534c00-1451427.jpg!d' />
              <Modal.Description>
                <Header>요율변경</Header>
                  회사 간 적용될 요율을 변경합니다. 
                  <p/>
                  <Form>
                    <Form.Field
                      control={Select}
                      options={genderOptions}
                      label={{ children: 'From', htmlFor: 'form-select-control-gender' }}
                      placeholder='요율명'
                      search
                      searchInput={{ id: 'form-select-control-gender' }}
                    />
                    <Form.Field
                      id='rate'
                      control={Input}
                      label='요율'
                      placeholder='%'
                    />
                    <Form.Field
                      id='submit'
                      control={Button}
                      content='변경'
                    />
                  </Form>
              </Modal.Description>
            </Modal.Content>
          </Modal>
        </Container>



        <Divider hidden />
        <Divider hidden />
        <Divider hidden />


        <Container text>      
          <Header as='h1' dividing>
            정산 내역 조회
          </Header>

          <Message>
            <Message.Header>데이터 1</Message.Header>
            <Message.List>
              <Message.Item>You can now have cover images on blog pages</Message.Item>
              <Message.Item>Drafts will now auto-save while writing</Message.Item>
            </Message.List>
          </Message>

          <Message>
            <Message.Header>데이터 2</Message.Header>
            <Message.List>
              <Message.Item>You can now have cover images on blog pages</Message.Item>
              <Message.Item>Drafts will now auto-save while writing</Message.Item>
            </Message.List>
          </Message> */}

          
        </Grid>
    );
  }
}

export default App;
