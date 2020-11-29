export interface PlayerInterface {
    id: string;
    status: string;
    tosAccepted: boolean;
}

const state: PlayerInterface = {
    id: '',
    status: '',
    tosAccepted: false
};

export default state;