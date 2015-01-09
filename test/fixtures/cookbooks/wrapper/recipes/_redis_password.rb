# Set password for Redis instance
node.run_state['magentostack'] = {
  'redis' => {
    'password_session' => 'runstatepasswordsession',
    'password_object' => 'runstatepasswordobject',
    'password_page' => 'runstatepasswordpage'
  }
}
