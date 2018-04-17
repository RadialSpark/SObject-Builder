# SObject-Builder
Collection of classes for supporting efficient and clean generation of test data

# Using the SObject Builder

No template

```
SObjectBuilder builder = new SObjectBuilder('Account');
builder
    .set('name', 'Test no template')
    .set('NumberOfEmployees', 300);
Account a = (Account)builder.validate().build(false);
```

With a template

```
SObjectBuilder builder = new SObjectBuilder(
  'Account', 
  new AccountTemplates.StandardAccountTemplate()
);
Account a = (Account)builder.validate().build(false);
```

Creating lists of records

```
SObjectBuilder builder = new SObjectBuilder(
  'Account', 
  new AccountTemplates.StandardAccountTemplate()
);
builder.count(3);
List<Account> a = (List<Account>)builder.validate().build(false);
```

Inserting record with the builder

```
Account a = (Account)builder.validate().build(true);
```

Reseting the values of a builder

```
builder.reset();
```

Changing templates (resets builder)

```
builder.setTemplate(new AccountTemplates.StandardAccountTemplate());
```

# Extending the Builder with Templates

An abstract Template class has been provided. In order to extend the behavior of the builder, create child classes which extend template and pass them into the constructor as arguments. This will give extended power over default values, as well as required values, per template.

