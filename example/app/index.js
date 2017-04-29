import React from 'react';
import {
  View,
  Button,
} from 'react-native';



export default class extends Component {
  render() {
    return (<View style={{ flex: 1, justifyContent: 'center', alignItems: 'center'}}>
      <Button title="login" />
    </View>);
  }
}
