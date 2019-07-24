//
//  Stripe.swift
//  DecreeServices
//
//  Created by Andrew J Wagner on 7/23/19.
//

import Foundation
import Decree

/// Stripe API
///
/// https://stripe.com/docs/api
public struct Stripe: WebService {
    public typealias BasicResponse = NoBasicResponse
    public typealias ErrorResponse = Types.Error

    public private(set) var authorization: Authorization = .none

    public mutating func configure(apiKey: String) {
        self.authorization = .basic(username: apiKey, password: "")
    }

    public static var shared = Stripe()
    public var sessionOverride: Session? = nil

    public let baseURL = URL(string: "https://api.stripe.com")!

    public func configure<E>(_ decoder: inout JSONDecoder, for endpoint: E) throws where E : Endpoint {
        decoder.dateDecodingStrategy = .secondsSince1970
    }
}

extension Stripe {
    public struct Types {
        public struct Error: AnyErrorResponse {
            public enum CodingKeys: String, CodingKey {
                case type, rawMessage = "message", charge, code, declineCode = "decline_code"
                case docURL = "doc_url"
            }

            public let type: Kind
            public let rawMessage: String
            public let code: Code?
            public let docURL: URL?

            // Card errors

            public let charge: String?
            public let declineCode: String?

            public var message: String {
                return self.rawMessage
            }
        }
    }

    public struct Plan: Decodable {
        public enum BillingScheme: String {
            case perUnit = "per_unit"
            case tiered
        }

        public let id: String
        public let object: String
        public let active: Bool
        public let amount: Int
        public let billingScheme = "billing_scheme"
        public let created: Date
        public let currency: Currency
        public let interval: Interval
        public let intervalCount: Int
        public let livemode: Bool
        public let metadata: [String:String]?
        public let nickname: String

        enum CodingKeys: String, CodingKey {
            case id, object, active, amount, billingScheme = "billing_scheme", created, currency, interval
            case intervalCount = "interval_count", livemode, nickname
        }
    }

    public enum Currency: String, Decodable {
        case usd,aed,afng,all,amd,ang,aoag,arsg,aud,awg,azn,bam,bbd,bdt,bgn,bif,bmd,bnd,bobg,brlg,bsd,bwp,bzd
        case cad,cdf,chf,clpg,cny,copg,crcg,cveg,czkg,djfg,dkk,dop,dzd,egp,etb,eur,fjd,fkpg,gbp,gel,gip,gmd
        case gnfg,gtqg,gyd,hkd,hnlg,hrk,htg,hufg,idr,ils,inrg,isk,jmd,jpy,kes,kgs,khr,kmf,krw,kyd,kzt,lakg,lbp
        case lkr,lrd,lsl,mad,mdl,mga,mkd,mmk,mnt,mop,mro,murg,mvr,mwk,mxn,myr,mzn,nad,ngn,niog,nok,npr,nzd
        case pabg,peng,pgk,php,pkr,pln,pygg,qar,ron,rsd,rub,rwf,sar,sbd,scr,sek,sgd,shpg,sll,sos,srdg,stdg,szl
        case thb,tjs,top,`try`,ttd,twd,tzs,uah,ugx,uyug,uzs,vnd,vuv,wst,xaf,xcd,xofg,xpfg,yer,zar,zmw
    }

    public enum Interval: String {
        case day, week, month, year
    }
}

extension Stripe.Types.Error {
    public enum Kind: String, Decodable {
        case connection = "api_connection_error"
        case api = "api_error"
        case authentication = "authentication_error"
        case card = "card_error"
        case idempotency = "idempotency_error"
        case invalidRequest = "invalid_request_error"
        case rateLimit = "rate_limit_error"
        case validation_error = "validation_error"
    }

    public enum Code: Decodable {
        case accountAlreadyExists
        case accountCountryInvalidAddress
        case accountInvalid
        case accountNumberInvalid
        case alipayUpgradeRequired
        case amountTooLarge
        case amountTooSmall
        case apiKeyExpired
        case balanceInsufficient
        case bankAccountExists
        case bankAccountUnusable
        case bankAccountUnverified
        case bitcoinUpgradeRequired
        case cardDeclined
        case chargeAlreadyCaptured
        case chargeAlreadyRefunded
        case chargeDisputed
        case chargeExceedsSourceLimit
        case chargeExpiredForCapture
        case countryUnsupported
        case couponExpired
        case customerMaxSubscriptions
        case emailInvalid
        case expiredCard
        case idempotencyKeyInUse
        case incorrectAddress
        case incorrectCVC
        case incorrectNumber
        case incorrectZip
        case instantPayoutsUnsupported
        case invalidCardType
        case invalidChargeAmount
        case invalidCVC
        case invalidExpiryMonth
        case invalidExpiryYear
        case invalidNumber
        case invalidSourceUsage
        case invoiceNoCustomerLineItems
        case invoiceNoSubscriptionLineItems
        case invoiceNotEditable
        case invoiceUpcomingNone
        case livemodeMismatch
        case missing
        case notAllowedOnStandardAccount
        case orderCreationFailed
        case orderRequiredSettings
        case orderStatusInvalid
        case orderUpstreamTimeout
        case outOfInventory
        case parameterInvalidEmpty
        case parameterInvalidInteger
        case parameterInvalidStringBlank
        case parameterInvalidStringEmpty
        case parameterMissing
        case parameterUnknown
        case parametersExclusive
        case paymentIntentAuthenticationFailure
        case paymentIntentIncompatiblePaymentMethod
        case paymentIntentInvalidParameter
        case paymentIntentPaymentAttemptFailed
        case paymentIntentUnexpectedState
        case paymentMethodUnactivated
        case paymentMethodUnexpected_state
        case payoutsNotAllowed
        case platformAPIKeyExpired
        case postalCodeInvalid
        case processingError
        case productInactive
        case rateLimit
        case resourceAlreadyExists
        case resourceMissing
        case routingNumberInvalid
        case secretKeyRequired
        case sepaUnsupportedAccount
        case setupAttemptFailed
        case setupIntentAuthenticationFailure
        case setupIntentUnexpectedState
        case shippingCalculationFailed
        case skuInactive
        case stateUnsupported
        case taxIdInvalid
        case taxesCalculationFailed
        case testmodeChargesOnly
        case tlsVersionUnsupported
        case tokenAlreadyUsed
        case tokenInUse
        case transfersNotAllowed
        case upstreamOrderCreationFailed
        case urlInvalid

        case other(String)

        public var details: String {
            switch self {
            case .accountAlreadyExists:
                return "The email address provided for the creation of a deferred account already has an account associated with it. Use the OAuth flow to connect the existing account to your platform."
            case .accountCountryInvalidAddress:
                return "The country of the business address provided does not match the country of the account. Businesses must be located in the same country as the account."
            case .accountInvalid:
                return "The account ID provided as a value for the Stripe-Account header is invalid. Check that your requests are specifying a valid account ID."
            case .accountNumberInvalid:
                return "The bank account number provided is invalid (e.g., missing digits). Bank account information varies from country to country. We recommend creating validations in your entry forms based on the bank account formats we provide."
            case .alipayUpgradeRequired:
                return "This method for creating Alipay payments is not supported anymore. Please upgrade your integration to use Sources instead."
            case .amountTooLarge:
                return "The specified amount is greater than the maximum amount allowed. Use a lower amount and try again."
            case .amountTooSmall:
                return "The specified amount is less than the minimum amount allowed. Use a higher amount and try again."
            case .apiKeyExpired:
                return "The API key provided has expired. Obtain your current API keys from the Dashboard and update your integration to use them."
            case .balanceInsufficient:
                return "The transfer or payout could not be completed because the associated account does not have a sufficient balance available. Create a new transfer or payout using an amount less than or equal to the account’s available balance."
            case .bankAccountExists:
                return "The bank account provided already exists on the specified Customer object. If the bank account should also be attached to a different customer, include the correct customer ID when making the request again."
            case .bankAccountUnusable:
                return "The bank account provided cannot be used for payouts. A different bank account must be used."
            case .bankAccountUnverified:
                return "Your Connect platform is attempting to share an unverified bank account with a connected account."
            case .bitcoinUpgradeRequired:
                return "This method for creating Bitcoin payments is not supported anymore. Please upgrade your integration to use Sources instead."
            case .cardDeclined:
                return "The card has been declined. When a card is declined, the error returned also includes the decline_code attribute with the reason why the card was declined. Refer to our decline codes documentation to learn more."
            case .chargeAlreadyCaptured:
                return "The charge you’re attempting to capture has already been captured. Update the request with an uncaptured charge ID."
            case .chargeAlreadyRefunded:
                return "The charge you’re attempting to refund has already been refunded. Update the request to use the ID of a charge that has not been refunded."
            case .chargeDisputed:
                return "The charge you’re attempting to refund has been charged back. Check the disputes documentation to learn how to respond to the dispute."
            case .chargeExceedsSourceLimit:
                return "This charge would cause you to exceed your rolling-window processing limit for this source type. Please retry the charge later, or contact us to request a higher processing limit."
            case .chargeExpiredForCapture:
                return "The charge cannot be captured as the authorization has expired. Auth and capture charges must be captured within seven days."
            case .countryUnsupported:
                return "Your platform attempted to create a custom account in a country that is not yet supported. Make sure that users can only sign up in countries supported by custom accounts."
            case .couponExpired:
                return "The coupon provided for a subscription or order has expired. Either create a new coupon, or use an existing one that is valid."
            case .customerMaxSubscriptions:
                return "The maximum number of subscriptions for a customer has been reached. Contact us if you are receiving this error."
            case .emailInvalid:
                return "The email address is invalid (e.g., not properly formatted). Check that the email address is properly formatted and only includes allowed characters."
            case .expiredCard:
                return "The card has expired. Check the expiration date or use a different card."
            case .idempotencyKeyInUse:
                return "The idempotency key provided is currently being used in another request. This occurs if your integration is making duplicate requests simultaneously."
            case .incorrectAddress:
                return "The card’s address is incorrect. Check the card’s address or use a different card."
            case .incorrectCVC:
                return "The card’s security code is incorrect. Check the card’s security code or use a different card."
            case .incorrectNumber:
                return "The card number is incorrect. Check the card’s number or use a different card."
            case .incorrectZip:
                return "The card’s ZIP code is incorrect. Check the card’s ZIP code or use a different card."
            case .instantPayoutsUnsupported:
                return "This card is not eligible for Instant Payouts. Try a debit card from a supported bank."
            case .invalidCardType:
                return "The card provided as an external account is not supported for payouts. Provide a non-prepaid debit card instead."
            case .invalidChargeAmount:
                return "The specified amount is invalid. The charge amount must be a positive integer in the smallest currency unit, and not exceed the minimum or maximum amount."
            case .invalidCVC:
                return "The card’s security code is invalid. Check the card’s security code or use a different card."
            case .invalidExpiryMonth:
                return "The card’s expiration month is incorrect. Check the expiration date or use a different card."
            case .invalidExpiryYear:
                return "The card’s expiration year is incorrect. Check the expiration date or use a different card."
            case .invalidNumber:
                return "The card number is invalid. Check the card details or use a different card."
            case .invalidSourceUsage:
                return "The source cannot be used because it is not in the correct state (e.g., a charge request is trying to use a source with a pending, failed, or consumed source). Check the status of the source you are attempting to use."
            case .invoiceNoCustomerLineItems:
                return "An invoice cannot be generated for the specified customer as there are no pending invoice items. Check that the correct customer is being specified or create any necessary invoice items first."
            case .invoiceNoSubscriptionLineItems:
                return "An invoice cannot be generated for the specified subscription as there are no pending invoice items. Check that the correct subscription is being specified or create any necessary invoice items first."
            case .invoiceNotEditable:
                return "The specified invoice can no longer be edited. Instead, consider creating additional invoice items that will be applied to the next invoice. You can either manually generate the next invoice or wait for it to be automatically generated at the end of the billing cycle."
            case .invoiceUpcomingNone:
                return "There is no upcoming invoice on the specified customer to preview. Only customers with active subscriptions or pending invoice items have invoices that can be previewed."
            case .livemodeMismatch:
                return "Test and live mode API keys, requests, and objects are only available within the mode they are in."
            case .missing:
                return "Both a customer and source ID have been provided, but the source has not been saved to the customer. To create a charge for a customer with a specified source, you must first save the card details."
            case .notAllowedOnStandardAccount:
                return "Transfers and payouts on behalf of a Standard connected account are not allowed."
            case .orderCreationFailed:
                return "The order could not be created. Check the order details and then try again."
            case .orderRequiredSettings:
                return "The order could not be processed as it is missing required information. Check the information provided and try again."
            case .orderStatusInvalid:
                return "The order cannot be updated because the status provided is either invalid or does not follow the order lifecycle (e.g., an order cannot transition from created to fulfilled without first transitioning to paid)."
            case .orderUpstreamTimeout:
                return "The request timed out. Try again later."
            case .outOfInventory:
                return "The SKU is out of stock. If more stock is available, update the SKU’s inventory quantity and try again."
            case .parameterInvalidEmpty:
                return "One or more required values were not provided. Make sure requests include all required parameters."
            case .parameterInvalidInteger:
                return "One or more of the parameters requires an integer, but the values provided were a different type. Make sure that only supported values are provided for each attribute. Refer to our API documentation to look up the type of data each attribute supports."
            case .parameterInvalidStringBlank:
                return "One or more values provided only included whitespace. Check the values in your request and update any that contain only whitespace."
            case .parameterInvalidStringEmpty:
                return "One or more required string values is empty. Make sure that string values contain at least one character."
            case .parameterMissing:
                return "One or more required values are missing. Check our API documentation to see which values are required to create or modify the specified resource."
            case .parameterUnknown:
                return "The request contains one or more unexpected parameters. Remove these and try again."
            case .parametersExclusive:
                return "Two or more mutually exclusive parameters were provided. Check our API documentation or the returned error message to see which values are permitted when creating or modifying the specified resource."
            case .paymentIntentAuthenticationFailure:
                return "The provided payment method has failed authentication. Provide a new payment method to attempt to fulfill this PaymentIntent again."
            case .paymentIntentIncompatiblePaymentMethod:
                return "The PaymentIntent expected a payment method with different properties than what was provided."
            case .paymentIntentInvalidParameter:
                return "One or more provided parameters was not allowed for the given operation on the PaymentIntent. Check our API reference or the returned error message to see which values were not correct for that PaymentIntent."
            case .paymentIntentPaymentAttemptFailed:
                return "The latest payment attempt for the PaymentIntent has failed. Check the last_payment_error property on the PaymentIntent for more details, and provide source_data or a new source to attempt to fulfill this PaymentIntent again."
            case .paymentIntentUnexpectedState:
                return "The PaymentIntent’s state was incompatible with the operation you were trying to perform."
            case .paymentMethodUnactivated:
                return "The charge cannot be created as the payment method used has not been activated. Activate the payment method in the Dashboard, then try again."
            case .paymentMethodUnexpected_state:
                return "The provided payment method’s state was incompatible with the operation you were trying to perform. Confirm that the payment method is in an allowed state for the given operation before attempting to perform it."
            case .payoutsNotAllowed:
                return "Payouts have been disabled on the connected account. Check the connected account’s status to see if any additional information needs to be provided, or if payouts have been disabled for another reason."
            case .platformAPIKeyExpired:
                return "The API key provided by your Connect platform has expired. This occurs if your platform has either generated a new key or the connected account has been disconnected from the platform. Obtain your current API keys from the Dashboard and update your integration, or reach out to the user and reconnect the account."
            case .postalCodeInvalid:
                return "The ZIP code provided was incorrect."
            case .processingError:
                return "An error occurred while processing the card. Check the card details are correct or use a different card."
            case .productInactive:
                return "The product this SKU belongs to is no longer available for purchase."
            case .rateLimit:
                return "Too many requests hit the API too quickly. We recommend an exponential backoff of your requests."
            case .resourceAlreadyExists:
                return "A resource with a user-specified ID (e.g., plan or coupon) already exists. Use a different, unique value for id and try again."
            case .resourceMissing:
                return "The ID provided is not valid. Either the resource does not exist, or an ID for a different resource has been provided."
            case .routingNumberInvalid:
                return "The bank routing number provided is invalid."
            case .secretKeyRequired:
                return "The API key provided is a publishable key, but a secret key is required. Obtain your current API keys from the Dashboard and update your integration to use them."
            case .sepaUnsupportedAccount:
                return "Your account does not support SEPA payments."
            case .setupAttemptFailed:
                return "The latest setup attempt for the SetupIntent has failed. Check the last_setup_error property on the SetupIntent for more details, and provide a new payment method to attempt to set it up again."
            case .setupIntentAuthenticationFailure:
                return "The provided payment method has failed authentication. Provide a new payment method to attempt to fulfill this SetupIntent again."
            case .setupIntentUnexpectedState:
                return "The SetupIntent’s state was incompatible with the operation you were trying to perform."
            case .shippingCalculationFailed:
                return "Shipping calculation failed as the information provided was either incorrect or could not be verified."
            case .skuInactive:
                return "The SKU is inactive and no longer available for purchase. Use a different SKU, or make the current SKU active again."
            case .stateUnsupported:
                return "Occurs when providing the legal_entity information for a U.S. custom account, if the provided state is not supported. (This is mostly associated states and territories.)"
            case .taxIdInvalid:
                return "The tax ID number provided is invalid (e.g., missing digits). Tax ID information varies from country to country, but must be at least nine digits."
            case .taxesCalculationFailed:
                return "Tax calculation for the order failed."
            case .testmodeChargesOnly:
                return "Your account has not been activated and can only make test charges. Activate your account in the Dashboard to begin processing live charges."
            case .tlsVersionUnsupported:
                return "Your integration is using an older version of TLS that is unsupported. You must be using TLS 1.2 or above."
            case .tokenAlreadyUsed:
                return "The token provided has already been used. You must create a new token before you can retry this request."
            case .tokenInUse:
                return "The token provided is currently being used in another request. This occurs if your integration is making duplicate requests simultaneously."
            case .transfersNotAllowed:
                return "The requested transfer cannot be created. Contact us if you are receiving this error."
            case .upstreamOrderCreationFailed:
                return "The order could not be created. Check the order details and then try again."
            case .urlInvalid:
                return "The URL provided is invalid."
            case .other(let name):
                return name
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            let raw = try container.decode(String.self)
            switch raw {
            case "account_already_exists":
                self = .accountAlreadyExists
            case "account_country_invalid_address":
                self = .accountCountryInvalidAddress
            case "account_invalid":
                self = .accountInvalid
            case "account_number_invalid":
                self = .accountNumberInvalid
            case "alipay_upgrade_required":
                self = .alipayUpgradeRequired
            case "amount_too_large":
                self = .amountTooLarge
            case "amount_too_small":
                self = .amountTooSmall
            case "api_key_expired":
                self = .apiKeyExpired
            case "balance_insufficient":
                self = .balanceInsufficient
            case "bank_account_exists":
                self = .bankAccountExists
            case "bank_account_unusable":
                self = .bankAccountUnusable
            case "bank_account_unverified":
                self = .bankAccountUnverified
            case "bitcoin_upgrade_required":
                self = .bitcoinUpgradeRequired
            case "card_declined":
                self = .cardDeclined
            case "charge_already_captured":
                self = .chargeAlreadyCaptured
            case "charge_already_refunded":
                self = .chargeAlreadyRefunded
            case "charge_disputed":
                self = .chargeDisputed
            case "charge_exceeds_source_limit":
                self = .chargeExceedsSourceLimit
            case "charge_expired_for_capture":
                self = .chargeExpiredForCapture
            case "country_unsupported":
                self = .countryUnsupported
            case "coupon_expired":
                self = .couponExpired
            case "customer_max_subscriptions":
                self = .customerMaxSubscriptions
            case "email_invalid":
                self = .emailInvalid
            case "expired_card":
                self = .expiredCard
            case "idempotency_key_in_use":
                self = .idempotencyKeyInUse
            case "incorrect_address":
                self = .incorrectAddress
            case "incorrect_cvc":
                self = .incorrectCVC
            case "incorrect_number":
                self = .incorrectNumber
            case "incorrect_zip":
                self = .incorrectZip
            case "instant_payouts_unsupported":
                self = .instantPayoutsUnsupported
            case "invalid_card_type":
                self = .invalidCardType
            case "invalid_charge_amount":
                self = .invalidChargeAmount
            case "invalid_cvc":
                self = .invalidCVC
            case "invalid_expiry_month":
                self = .invalidExpiryMonth
            case "invalid_expiry_year":
                self = .invalidExpiryYear
            case "invalid_number":
                self = .invalidNumber
            case "invalid_source_usage":
                self = .invalidSourceUsage
            case "invoice_no_customer_line_items":
                self = .invoiceNoCustomerLineItems
            case "invoice_no_subscription_line_items":
                self = .invoiceNoSubscriptionLineItems
            case "invoice_not_editable":
                self = .invoiceNotEditable
            case "invoice_upcoming_none":
                self = .invoiceUpcomingNone
            case "livemode_mismatch":
                self = .livemodeMismatch
            case "missing":
                self = .missing
            case "not_allowed_on_standard_account":
                self = .notAllowedOnStandardAccount
            case "order_creation_failed":
                self = .orderCreationFailed
            case "order_required_settings":
                self = .orderRequiredSettings
            case "order_status_invalid":
                self = .orderStatusInvalid
            case "order_upstream_timeout":
                self = .orderUpstreamTimeout
            case "out_of_inventory":
                self = .outOfInventory
            case "parameter_invalid_empty":
                self = .parameterInvalidEmpty
            case "parameter_invalid_integer":
                self = .parameterInvalidInteger
            case "parameter_invalid_string_blank":
                self = .parameterInvalidStringBlank
            case "parameter_invalid_string_empty":
                self = .parameterInvalidStringEmpty
            case "parameter_missing":
                self = .parameterMissing
            case "parameter_unknown":
                self = .parameterUnknown
            case "parameters_exclusive":
                self = .parametersExclusive
            case "payment_intent_authentication_failure":
                self = .paymentIntentAuthenticationFailure
            case "payment_intent_incompatible_payment_method":
                self = .paymentIntentIncompatiblePaymentMethod
            case "payment_intent_invalid_parameter":
                self = .paymentIntentInvalidParameter
            case "payment_intent_payment_attempt_failed":
                self = .paymentIntentPaymentAttemptFailed
            case "payment_intent_unexpected_state":
                self = .paymentIntentUnexpectedState
            case "payment_method_unactivated":
                self = .paymentMethodUnactivated
            case "payment_method_unexpected_state":
                self = .paymentMethodUnexpected_state
            case "payouts_not_allowed":
                self = .payoutsNotAllowed
            case "platform_api_key_expired":
                self = .platformAPIKeyExpired
            case "postal_code_invalid":
                self = .postalCodeInvalid
            case "processing_error":
                self = .processingError
            case "product_inactive":
                self = .productInactive
            case "rate_limit":
                self = .rateLimit
            case "resource_already_exists":
                self = .resourceAlreadyExists
            case "resource_missing":
                self = .resourceMissing
            case "routing_number_invalid":
                self = .routingNumberInvalid
            case "secret_key_required":
                self = .secretKeyRequired
            case "sepa_unsupported_account":
                self = .sepaUnsupportedAccount
            case "setup_attempt_failed":
                self = .setupAttemptFailed
            case "setup_intent_authentication_failure":
                self = .setupIntentAuthenticationFailure
            case "setup_intent_unexpected_state":
                self = .setupIntentUnexpectedState
            case "shipping_calculation_failed":
                self = .shippingCalculationFailed
            case "sku_inactive":
                self = .skuInactive
            case "state_unsupported":
                self = .stateUnsupported
            case "tax_id_invalid":
                self = .taxIdInvalid
            case "taxes_calculation_failed":
                self = .taxesCalculationFailed
            case "testmode_charges_only":
                self = .testmodeChargesOnly
            case "tls_version_unsupported":
                self = .tlsVersionUnsupported
            case "token_already_used":
                self = .tokenAlreadyUsed
            case "token_in_use":
                self = .tokenInUse
            case "transfers_not_allowed":
                self = .transfersNotAllowed
            case "upstream_order_creation_failed":
                self = .upstreamOrderCreationFailed
            case "url_invalid":
                self = .urlInvalid
            default:
                self = .other(raw)
            }
        }
    }
}
