export interface LinkInterface {
  id: string;
  arrivalText: string;
  departureText: string;
  shortDescription: string;
  longDescription: string;
  type: string;
  icon: string;
  toId: string;
  fromId: string;
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
  localFromLabelRotation: number;
  localFromLabelHorizontalOffset: number;
  localFromLabelVerticalOffset: number;
  localFromLabelFontSize: number;
  localToLabel: string;
  localToLabelRotation: number;
  localToLabelHorizontalOffset: number;
  localToLabelVerticalOffset: number;
  localToLabelFontSize: number;
  label: string;
  labelRotation: number;
  labelHorizontalOffset: number;
  labelVerticalOffset: number;
  labelFontSize: number;
}

const state: LinkInterface = {
  id: "",
  arrivalText: "",
  departureText: "",
  shortDescription: "",
  longDescription: "",
  icon: "fas-fa-compass",
  type: "Direction",
  toId: "",
  fromId: "",
  localFromX: 0,
  localFromY: 0,
  localFromCorners: 5,
  localFromSize: 21,
  localFromColor: "#008080",
  localToX: 0,
  localToY: 0,
  localToCorners: 5,
  localToSize: 21,
  localToColor: "#008080",
  localFromLabel: "",
  localFromLabelRotation: 0,
  localFromLabelHorizontalOffset: 0,
  localFromLabelVerticalOffset: 0,
  localFromLabelFontSize: 12,
  localToLabel: "",
  localToLabelRotation: 0,
  localToLabelHorizontalOffset: 0,
  localToLabelVerticalOffset: 0,
  localToLabelFontSize: 12,
  label: "",
  labelRotation: 0,
  labelHorizontalOffset: 0,
  labelVerticalOffset: 0,
  labelFontSize: 12,
};

export default state;
