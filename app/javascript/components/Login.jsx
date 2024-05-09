import React, { useState, useEffect } from 'react';
import { usePrivy, getAccessToken } from '@privy-io/react-auth';
import axios from 'axios';

const Login = () => {
  const { ready, authenticated, user, login, logout } = usePrivy();
  const [accessToken, setAccessToken] = useState(null);
  const [isUserCreated, setIsUserCreated] = useState(false);

  useEffect(() => {
    const fetchAccessToken = async () => {
      const token = await getAccessToken();
      setAccessToken(token);
    };

    fetchAccessToken();
  }, [authenticated]);


  useEffect(() => {
    if(user){
      createUser();
    }
  }, [user]);

  const createUser = async () => {
    const userID = new URLSearchParams(window.location.search).get('userid');
    console.log(userID)
    if(userID && accessToken){
      console.log(accessToken)
      const response = await axios.post('http://localhost:3000/create_user', {
        user_id: userID,
        access_token: accessToken,
      });
      if(response.status === 200){
        setIsUserCreated(true)
      }
      console.log(response);
    }
      
  };

  if (!ready) {
    return <div className="loading">Loading...</div>;
  }

  if (!authenticated) {
    return (
      <div className="success-message">
        <button onClick={login} className="login-button">
          Signup
        </button>
      </div>
    );
  }

  if (authenticated && isUserCreated) {
    return (
      <div className="success-message">
        <div>Your are successfully logged in. Please go to your Telegram app and use your bot.</div>
        <button onClick={logout} className="logout-button">
          Logout
        </button>
      </div>
    );
  }
};

export default Login;
