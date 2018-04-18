import { storiesOf } from "@storybook/react-native"
import React from "react"

import BidFlow from "../Screens/BidFlow"
import { BidResult } from "../Screens/BidResult"
import { SelectMaxBid } from "../Screens/SelectMaxBid"

storiesOf("Bidding")
  .add("Show bid flow", () => {
    return <BidFlow saleArtworkID="5aada729139b216c0bf18103" />
  })
  .add("Select Max Bid", () => {
    return <SelectMaxBid saleArtworkID="5aada729139b216c0bf18103" />
  })
  .add("Bidding Result (winning)", () => {
    return <BidResult winning />
  })
  .add("Bidding Result (not highest bid)", () => {
    return <BidResult winning={false} />
  })
