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
    localToX: number
    localToY: number
    localToSize: number
    localFromX: number
    localFromY: number
    localFromSize: number
  }
  
  const state: LinkInterface = {
    id: '',
    arrivalText: '',
    departureText: '',
    shortDescription: '',
    longDescription: '',
    icon: '',
    type: '',
    toId: '',
    fromId: '',
    localFromX: 0,
    localFromY: 0,
    localFromSize: 20,
    localToX: 0,
    localToY: 0,
    localToSize: 20,
  };
  
  export default state;
  