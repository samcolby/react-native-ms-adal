import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button,
} from 'react-native';

import { MSAdalLogin, MSAdalLogout } from '/MSAdal';

const authority = 'https://login.microsoftonline.com/common';
const clientId = '';
const redirectUri = 'http://localhost';
const resourceUri = '';

export default class adalExample extends Component {

  constructor(props) {
    super(props);
    this.state = {
      isLoggedin: false,
      givenName: '',
    }
  }

  renderLogin() {
    return (
      <Button title="login" onPress={() => {
        MSAdalLogin(authority, clientId, redirectUri, resourceUri)
        .then((authDetails) => {
          this.setState({
            isLoggedin: true,
            givenName: authDetails.userInfo.givenName
          })
        })
      }} />
    );
  }

  renderLogout() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Hi {this.state.givenName}!</Text>
        <Button title="logout" onPress={() => {
          MSAdalLogout(authority, redirectUri)
          .then(() => {
            this.setState({
              isLoggedin: false,
              givenName: '',
            })
          })
        }} />

      </View>
    );
  }

  render() {
    return (
      <View style={styles.container}>
        {
          this.state.isLoggedin
            ? this.renderLogout()
            : this.renderLogin()
        }
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 20,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
