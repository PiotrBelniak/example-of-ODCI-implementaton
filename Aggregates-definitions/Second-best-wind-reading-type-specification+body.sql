CREATE OR REPLACE EDITIONABLE TYPE "C##METEO"."SECONDBESTWINDIMPL" as object
(best_val NUMBER,
secbest NUMBER,
static function ODCIAggregateInitialize(sctx IN OUT SecondBestWindImpl) return number,
member function ODCIAggregateIterate(self IN OUT SecondBestWindImpl, value IN METEO_T) return number,
member function ODCIAggregateTerminate(self IN OUT SecondBestWindImpl, returnVal OUT number, flags IN NUMBER) return number,
member function ODCIAggregateMerge(self IN OUT SecondBestWindImpl, ctx2 IN SecondBestWindImpl) return number);
/
CREATE OR REPLACE EDITIONABLE TYPE BODY "C##METEO"."SECONDBESTWINDIMPL" 
IS
    static function ODCIAggregateInitialize(sctx IN OUT SecondBestWindImpl) return number
    IS
    BEGIN
        sctx:=SecondBestWindImpl(99,100);
        return ODCIConst.Success;
    END ODCIAggregateInitialize;
    member function ODCIAggregateIterate(self IN OUT SecondBestWindImpl, value IN METEO_T) return number
    IS
        curval NUMBER;
    BEGIN
        FOR indx IN value.Zonereadings.FIRST..value.Zonereadings.LAST LOOP
            IF value.Zonereadings(indx).avg_wind<curval OR curval IS NULL THEN
                curval:=value.Zonereadings(indx).avg_wind;
            END IF;
        END LOOP;
        IF curval<self.best_val THEN
            self.secbest:=self.best_val;
            self.best_val:=curval;
        ELSIF curval> self.best_val AND curval<self.secbest THEN
            self.secbest:=curval;
        END IF;
        return ODCICOnst.Success;
    END ODCIAggregateIterate;
    member function ODCIAggregateTerminate(self IN OUT SecondBestWindImpl, returnVal OUT number, flags IN NUMBER) return number
    IS
    BEGIN
        IF self.secbest=99 OR self.secbest=100 THEN
            returnVal:=self.best_val;
        ELSE
            returnVal:=self.secbest;
        END IF;
        return ODCIConst.Success;
    END ODCIAggregateTerminate;

    member function ODCIAggregateMerge(self IN OUT SecondBestWindImpl, ctx2 IN SecondBestWindImpl) return number
    IS
    BEGIN
        IF ctx2.secbest<self.best_val THEN
            self.secbest:=ctx2.secbest;
            self.best_val:=ctx2.best_val;
        ELSIF ctx2.best_val<self.best_val THEN
            self.secbest:=self.best_val;
            self.best_val:=ctx2.best_val;
        ELSIF ctx2.best_val<self.secbest THEN
            self.secbest:=ctx2.best_val;
        END IF;
        return ODCIConst.Success;
    END ODCIAggregateMerge;
END;

/
