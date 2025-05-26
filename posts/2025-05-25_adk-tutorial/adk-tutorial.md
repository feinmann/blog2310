# Google Agent Development Kit (ADK): Complete Tutorial
3atthias 3erger
2025-05-25

## Introduction

The Google Agent Development Kit (ADK) is a comprehensive framework
designed to help developers build, test, and deploy intelligent
conversational agents. Built on Google’s extensive AI and machine
learning infrastructure, the ADK provides tools and libraries that
simplify the process of creating sophisticated chatbots, virtual
assistants, and automated customer service agents.

The ADK integrates seamlessly with Google’s ecosystem, including
Dialogflow, Cloud Functions, and various Google Cloud services, making
it an ideal choice for developers looking to leverage Google’s AI
capabilities in their applications.

## Prerequisites

Before diving into the Google ADK, ensure you have the following
prerequisites:

- A Google Cloud Platform (GCP) account with billing enabled
- Node.js (version 14 or higher) installed on your system
- Basic understanding of JavaScript/TypeScript
- Familiarity with REST APIs and webhooks
- Git for version control

## Installation and Setup

### Installing the ADK CLI

The Google ADK Command Line Interface is the primary tool for managing
your agent projects. Install it globally using npm:

<div class="code-with-filename">

**Terminal**

``` bash
$ npm install -g @google/adk-cli
```

</div>

For Arch Linux users, you may need to install Node.js and npm first:

<div class="code-with-filename">

**Terminal**

``` bash
$ sudo pacman -S nodejs npm
$ npm install -g @google/adk-cli
```

</div>

### Authentication Setup

Before using the ADK, you need to authenticate with Google Cloud:

<div class="code-with-filename">

**Terminal**

``` bash
$ gcloud auth login
$ gcloud config set project YOUR_PROJECT_ID
$ adk auth login
```

</div>

### Verifying Installation

Confirm that the ADK CLI is properly installed:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk --version
$ adk help
```

</div>

## Creating Your First Agent

### Project Initialization

Create a new ADK project using the CLI:

<div class="code-with-filename">

**Terminal**

``` bash
$ mkdir my-first-agent
$ cd my-first-agent
$ adk init
```

</div>

The initialization process will prompt you for several configuration
options:

- Project name
- Default language
- Integration preferences
- Deployment target

### Project Structure

After initialization, your project will have the following structure:

    my-first-agent/
    ├── src/
    │   ├── intents/
    │   ├── entities/
    │   ├── handlers/
    │   └── config/
    ├── tests/
    ├── package.json
    ├── adk.config.js
    └── README.md

### Basic Configuration

Edit the `adk.config.js` file to configure your agent’s basic settings:

``` javascript
module.exports = {
  projectId: 'your-project-id',
  defaultLanguage: 'en',
  timeZone: 'America/New_York',
  enableLogging: true,
  integrations: {
    dialogflow: true,
    assistant: true
  }
};
```

## Defining Intents and Entities

### Creating Intents

Intents represent the user’s intention when interacting with your agent.
Create a new intent:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk generate intent greeting
```

</div>

This creates a new intent file in `src/intents/greeting.js`:

``` javascript
module.exports = {
  name: 'greeting',
  trainingPhrases: [
    'Hello',
    'Hi there',
    'Good morning',
    'Hey'
  ],
  responses: [
    'Hello! How can I help you today?',
    'Hi! What can I do for you?',
    'Greetings! How may I assist you?'
  ]
};
```

### Creating Entities

Entities extract specific information from user input. Generate a new
entity:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk generate entity product
```

</div>

Edit the generated entity file in `src/entities/product.js`:

``` javascript
module.exports = {
  name: 'product',
  entityType: 'ENTITY_TYPE_ENUM',
  entities: [
    {
      value: 'laptop',
      synonyms: ['notebook', 'computer', 'pc']
    },
    {
      value: 'smartphone',
      synonyms: ['phone', 'mobile', 'cell phone']
    }
  ]
};
```

## Building Custom Handlers

### Handler Functions

Handlers contain the business logic for processing user requests. Create
a custom handler:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk generate handler order-status
```

</div>

Implement the handler in `src/handlers/order-status.js`:

``` javascript
const { Handler } = require('@google/adk');

class OrderStatusHandler extends Handler {
  async handle(request) {
    const orderId = request.parameters.orderId;
    
    // Simulate order lookup
    const orderStatus = await this.lookupOrder(orderId);
    
    return {
      fulfillmentText: `Your order ${orderId} is currently ${orderStatus}`,
      outputContexts: [{
        name: 'order-context',
        lifespanCount: 5,
        parameters: { orderId, status: orderStatus }
      }]
    };
  }
  
  async lookupOrder(orderId) {
    // Implementation for order lookup
    return 'in transit';
  }
}

module.exports = OrderStatusHandler;
```

### Webhook Integration

Configure webhooks for dynamic responses:

``` javascript
// src/config/webhooks.js
module.exports = {
  endpoints: [
    {
      intent: 'order.status',
      handler: 'order-status',
      method: 'POST'
    }
  ]
};
```

## Testing Your Agent

### Local Testing

Run your agent locally for development testing:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk serve --port 3000
```

</div>

### Unit Testing

Create and run unit tests for your handlers:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk test
$ adk test --coverage
```

</div>

### Integration Testing

Test your agent with the ADK simulator:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk simulate "Hello, I want to check my order status"
```

</div>

## Deployment

### Building for Production

Prepare your agent for deployment:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk build --env production
```

</div>

### Deploying to Google Cloud

Deploy your agent to Google Cloud Platform:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk deploy --target gcp
```

</div>

### Environment Configuration

Configure different environments:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk config set-env staging --project staging-project-id
$ adk deploy --env staging
```

</div>

## Advanced Features

### Multi-language Support

Configure multiple languages for your agent:

``` javascript
// adk.config.js
module.exports = {
  languages: ['en', 'es', 'fr'],
  defaultLanguage: 'en'
};
```

Generate language-specific intents:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk generate intent greeting --lang es
```

</div>

### Context Management

Implement conversation context:

``` javascript
// src/handlers/context-handler.js
class ContextHandler extends Handler {
  async handle(request) {
    const context = request.queryResult.outputContexts;
    const userContext = this.extractUserContext(context);
    
    // Use context to maintain conversation state
    return this.generateContextualResponse(userContext);
  }
}
```

### Analytics and Monitoring

Enable analytics for your agent:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk analytics enable
$ adk analytics dashboard
```

</div>

## Shell Differences: Fish vs Bash

### Using ADK CLI in Bash

In Bash, the ADK CLI works with standard shell features:

<div class="code-with-filename">

**Terminal**

``` bash
$ export ADK_PROJECT_ID="my-project-123"
$ adk deploy --project $ADK_PROJECT_ID
$ history | grep adk  # View command history
```

</div>

Bash tab completion for ADK commands:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk dep<TAB>    # Expands to "adk deploy"
$ adk generate <TAB><TAB>  # Shows available generators
```

</div>

### Using ADK CLI in Fish

Fish shell provides enhanced features for ADK development:

<div class="code-with-filename">

**Terminal**

``` bash
$ set -x ADK_PROJECT_ID "my-project-123"  # Fish environment variable syntax
$ adk deploy --project $ADK_PROJECT_ID
$ history --search adk  # Fish-specific history search
```

</div>

Fish offers superior autocompletion and syntax highlighting:

- Fish automatically suggests commands based on history
- Syntax highlighting shows valid/invalid commands in real-time
- More intuitive tab completion with descriptions

Fish-specific ADK aliases:

<div class="code-with-filename">

**Terminal**

``` bash
$ alias adks='adk serve --port 3000'
$ alias adkt='adk test --watch'
$ alias adkd='adk deploy --env production'
```

</div>

### Arch Linux Specific Considerations

On Arch Linux, you may need additional packages:

<div class="code-with-filename">

**Terminal**

``` bash
$ sudo pacman -S base-devel python  # Required for native modules
$ yay -S google-cloud-sdk  # For gcloud CLI (AUR)
```

</div>

## Troubleshooting

### Common Issues

1.  **Authentication Errors**: Ensure proper GCP authentication
2.  **Port Conflicts**: Use different ports for local development
3.  **Dependency Issues**: Clear npm cache and reinstall

<div class="code-with-filename">

**Terminal**

``` bash
$ npm cache clean --force
$ rm -rf node_modules package-lock.json
$ npm install
```

</div>

### Debug Mode

Enable verbose logging for troubleshooting:

<div class="code-with-filename">

**Terminal**

``` bash
$ adk serve --debug --verbose
$ adk deploy --dry-run  # Preview deployment without executing
```

</div>

## Best Practices

### Code Organization

- Keep intents focused and specific
- Use meaningful entity names
- Implement proper error handling
- Follow consistent naming conventions

### Performance Optimization

- Cache frequently accessed data
- Minimize external API calls
- Use appropriate timeout values
- Implement proper logging

### Security Considerations

- Validate all user inputs
- Use HTTPS for webhooks
- Implement proper authentication
- Follow Google Cloud security best practices

## Conclusion

The Google Agent Development Kit provides a robust framework for
building intelligent conversational agents. By following this tutorial,
you’ve learned the fundamentals of creating, testing, and deploying
agents using the ADK. The framework’s integration with Google’s AI
services makes it a powerful choice for developers looking to create
sophisticated conversational experiences.

Continue exploring the ADK documentation and experiment with advanced
features like machine learning integration, custom fulfillment, and
multi-modal interactions to create even more engaging agents.

## Interesting Fact

The Google ADK’s intent matching system uses advanced natural language
processing that can understand user input even with typos and
grammatical errors. The system employs fuzzy matching algorithms that
can correctly interpret “I wan to chck my odrer” as “I want to check my
order” with over 95% accuracy, making your agents more robust and
user-friendly in real-world scenarios.
