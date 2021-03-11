import type { LinkFlagsInterface } from "./linkFlags";
import LinkFlagsState from "./linkFlags";

import type { LinkClosableInterface } from "./linkClosable";
import LinkClosableState from "./linkClosable";

export interface LinkInterface {
  id: string;
  arrivalText: string;
  departureText: string;
  shortDescription: string;
  longDescription: string;
  type: string;
  icon: string;
  corners: number;
  toId: string;
  fromId: string;
  lineEndHorizontalOffsetWidth: number;
  lineEndVerticalOffsetWidth: number;
  lineStartHorizontalOffsetWidth: number;
  lineStartVerticalOffsetWidth: number;
  hasMarker: boolean;
  markerOffset: number;
  lineWidth: number;
  lineDash: number;
  lineColor: string;
  localToX: number;
  localToY: number;
  localToCorners: number;
  localToSize: number;
  localToColor: string;
  localFromX: number;
  localFromY: number;
  localFromCorners: number;
  localFromSize: number;
  localFromColor: string;
  localFromLabel: string;
  localFromLabelColor: string;
  localFromLabelRotation: number;
  localFromLabelHorizontalOffset: number;
  localFromLabelVerticalOffset: number;
  localFromLabelFontSize: number;
  localFromLineWidth: number;
  localFromLineDash: number;
  localFromLineColor: string;
  localFromBorderWidth: number;
  localFromBorderColor: string;
  localToLabel: string;
  localToLabelColor: string;
  localToLabelRotation: number;
  localToLabelHorizontalOffset: number;
  localToLabelVerticalOffset: number;
  localToLabelFontSize: number;
  localToBorderWidth: number;
  localToBorderColor: string;
  label: string;
  labelColor: string;
  labelRotation: number;
  labelHorizontalOffset: number;
  labelVerticalOffset: number;
  labelFontSize: number;
  localToLineWidth: number;
  localToLineDash: number;
  localToLineColor: string;
  flags: LinkFlagsInterface;
  closable: LinkClosableInterface;
}

const state: LinkInterface = {
  id: "",
  arrivalText: "",
  departureText: "",
  shortDescription: "",
  longDescription: "",
  icon: "fas-fa-compass",
  type: "direction",
  toId: "",
  fromId: "",
  hasMarker: false,
  markerOffset: 4,
  localFromX: 0,
  localFromY: 0,
  localFromCorners: 5,
  localFromSize: 20,
  localFromColor: "#008080",
  localFromLabelColor: "#FFFFFF",
  localToX: 0,
  localToY: 0,
  localToCorners: 5,
  localToSize: 20,
  localToColor: "#008080",
  localFromLabel: "",
  localFromLabelRotation: 0,
  localFromLabelHorizontalOffset: 0,
  localFromLabelVerticalOffset: 0,
  localFromLabelFontSize: 8,
  localFromBorderWidth: 2,
  localFromBorderColor: "#FFFFFF",
  localToLabel: "",
  localToLabelRotation: 0,
  localToLabelHorizontalOffset: 0,
  localToLabelVerticalOffset: 0,
  localToLabelFontSize: 8,
  localToLabelColor: "#FFFFFF",
  localToLineWidth: 2,
  localToLineDash: 0,
  localToLineColor: "#FFFFFF",
  localToBorderWidth: 2,
  localToBorderColor: "#FFFFFF",
  label: "",
  labelColor: "#FFFFFF",
  labelRotation: 0,
  labelHorizontalOffset: 0,
  labelVerticalOffset: 0,
  labelFontSize: 8,
  localFromLineWidth: 2,
  localFromLineDash: 0,
  localFromLineColor: "#FFFFFF",
  lineWidth: 2,
  lineDash: 0,
  lineColor: "#FFFFFF",
  corners: 5,
  lineEndHorizontalOffsetWidth: 0,
  lineEndVerticalOffsetWidth: 0,
  lineStartHorizontalOffsetWidth: 0,
  lineStartVerticalOffsetWidth: 0,
  flags: { ...LinkFlagsState },
  closable: { ...LinkClosableState },
};

export default state;