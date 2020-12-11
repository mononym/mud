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
  localFromLabelFlipped: boolean;
  localFromLabelHorizontalOffset: number;
  localFromLabelVerticalOffset: number;
  localFromLabelFontSize: number;
  localToLabel: string;
  localToLabelFlipped: boolean;
  localToLabelHorizontalOffset: number;
  localToLabelVerticalOffset: number;
  localToLabelFontSize: number;
  label: string;
  labelFlipped: boolean;
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
  localFromLabelFlipped: false,
  localFromLabelHorizontalOffset: 0,
  localFromLabelVerticalOffset: 0,
  localFromLabelFontSize: 26,
  localToLabel: "",
  localToLabelFlipped: false,
  localToLabelHorizontalOffset: 0,
  localToLabelVerticalOffset: 0,
  localToLabelFontSize: 26,
  label: "",
  labelFlipped: false,
  labelHorizontalOffset: 0,
  labelVerticalOffset: 0,
  labelFontSize: 26,
};

export default state;
