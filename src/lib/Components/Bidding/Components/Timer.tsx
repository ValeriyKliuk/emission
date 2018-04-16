import moment from "moment"
import React from "react"
import styled from "styled-components/native"

interface BidResultProps {
  // TODO: Change ths to endsAt or until: ISO8601
  timeLeftInMilliseconds: number
}

interface BidResultState {
  timeLeftInMilliseconds: number
}

export class Timer extends React.Component<BidResultProps, BidResultState> {
  private intervalId: number

  constructor(props) {
    super(props)

    this.state = {
      timeLeftInMilliseconds: this.props.timeLeftInMilliseconds,
    }
  }

  timer = () => {
    this.setState({
      timeLeftInMilliseconds: this.state.timeLeftInMilliseconds - 1000,
    })
  }

  componentDidMount() {
    this.intervalId = setInterval(this.timer, 1000)
  }

  componentWillUnmount() {
    clearInterval(this.intervalId)
  }

  render() {
    const duration = moment.duration(this.state.timeLeftInMilliseconds)

    return (
      <TimerText>
        {duration.days()}d&nbsp;
        {duration.hours()}h&nbsp;
        {duration.minutes()}m&nbsp;
        {duration.seconds()}s
      </TimerText>
    )
  }
}

const TimerText = styled.Text`
  font-size: 14px;
  font-weight: 500;
  color: #000000;
`
